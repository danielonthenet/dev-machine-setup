#!/bin/bash

# =============================================================================
# Shared Dotfiles Setup Functions
# =============================================================================
# 
# This library provides common dotfiles installation and configuration 
# functions that can be sourced by platform-specific setup scripts.
# 
# Functions provided:
# - setup_dotfiles_environment()  - Sets up directory variables and detection
# - backup_existing_files()       - Backs up existing config files
# - create_symlinks()             - Creates dotfiles symlinks
# - install_dotfiles()            - Main dotfiles installation function
# - validate_dotfiles()           - Validates dotfiles installation
#
# Usage:
#   ./common/setup_dotfiles.sh [options]
#   Or call specific functions by sourcing:
#   source common/setup_dotfiles.sh && install_dotfiles
#
# =============================================================================

set -euo pipefail

# ============================================================================= 
# Environment Setup
# =============================================================================

setup_dotfiles_environment() {
    # Get script directory - handle both standalone and sourced execution
    if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
        local script_path="${BASH_SOURCE[0]}"
        # If sourced, get the directory of the sourcing script
        if [[ "${BASH_SOURCE[1]:-}" ]]; then
            script_path="${BASH_SOURCE[1]}"
        fi
        DOTFILES_DIR="$(cd "$(dirname "$script_path")/.." && pwd)"
    else
        DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
    fi

    # Export directory variables for use by other scripts
    export DOTFILES_DIR
    export DOTFILES_COMMON_DIR="$DOTFILES_DIR/common"
    
    # Source OS detection
    if [[ -f "$DOTFILES_COMMON_DIR/detect_os.sh" ]]; then
        source "$DOTFILES_COMMON_DIR/detect_os.sh"
    else
        echo "❌ OS detection script not found: $DOTFILES_COMMON_DIR/detect_os.sh"
        return 1
    fi
    
    # Set platform-specific directory
    case "$DOTFILES_OS" in
        "macos")
            export DOTFILES_OS_DIR="$DOTFILES_DIR/macos"
            ;;
        "linux")
            export DOTFILES_OS_DIR="$DOTFILES_DIR/linux"
            ;;
        "windows")
            export DOTFILES_OS_DIR="$DOTFILES_DIR/windows"
            ;;
        *)
            echo "❌ Unsupported OS: $DOTFILES_OS"
            return 1
            ;;
    esac
    
    # Setup logging
    DOTFILES_LOG_FILE="${DOTFILES_LOG_FILE:-$HOME/.dotfiles-install.log}"
    export DOTFILES_LOG_FILE
}

# Logging function
dotfiles_log() {
    local log_file="${DOTFILES_LOG_FILE:-$HOME/.dotfiles-install.log}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$log_file"
}

# =============================================================================
# Prerequisites Check
# =============================================================================

check_dotfiles_prerequisites() {
    dotfiles_log "🔍 Checking dotfiles prerequisites..."
    
    # Check if running in supported shell
    if [[ ! "$SHELL" =~ (bash|zsh) ]]; then
        echo "❌ Unsupported shell: $SHELL"
        echo "Please switch to bash or zsh first"
        return 1
    fi
    
    # Check internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        echo "❌ No internet connection detected"
        echo "Please check your internet connection and try again"
        return 1
    fi
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        echo "❌ Git is not installed"
        echo "Please install git first"
        return 1
    fi
    
    dotfiles_log "✅ Prerequisites check passed"
}

# =============================================================================
# Backup Functions
# =============================================================================

backup_existing_files() {
    dotfiles_log "📦 Backing up existing configuration files..."

    # Backup existing files if they exist and aren't symlinks
    backup_if_exists() {
        local file="$1"
        if [[ -f "$file" && ! -L "$file" ]]; then
            local backup_name="${file}.backup.$(date +%Y%m%d_%H%M%S)"
            dotfiles_log "📦 Backing up existing $file to $backup_name"
            mv "$file" "$backup_name"
        fi
    }

    # Common config files to backup (excluding .gitconfig which is handled in generate_gitconfig)
    backup_if_exists "$HOME/.gitignore_global" 
    backup_if_exists "$HOME/.vimrc"
    backup_if_exists "$HOME/.zshrc"
    backup_if_exists "$HOME/.p10k.zsh"
    backup_if_exists "$HOME/.bashrc"
    backup_if_exists "$HOME/.bash_profile"
    
    dotfiles_log "✅ Backup completed"
}

# =============================================================================
# Symlink Creation
# =============================================================================

create_symlinks() {
    dotfiles_log "🔗 Creating dotfiles symlinks..."

    # Function to create symlink with error handling
    create_symlink() {
        local source="$1"
        local target="$2"
        
        if [[ ! -f "$source" ]]; then
            dotfiles_log "⚠️  Source file not found: $source"
            return 1
        fi
        
        # Remove existing symlink or file
        if [[ -L "$target" ]]; then
            rm "$target"
        fi
        
        # Create symlink
        ln -sf "$source" "$target"
        dotfiles_log "🔗 Created symlink: $target -> $source"
    }

    # Create symlinks for common dotfiles (excluding .gitconfig which is generated from template)
    create_symlink "$DOTFILES_COMMON_DIR/.gitignore_global" "$HOME/.gitignore_global"
    create_symlink "$DOTFILES_COMMON_DIR/.vimrc" "$HOME/.vimrc"
    create_symlink "$DOTFILES_COMMON_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    create_symlink "$DOTFILES_COMMON_DIR/.zshrc" "$HOME/.zshrc"

    # Copy .vim directory if it exists
    if [[ -d "$DOTFILES_DIR/.vim" ]]; then
        dotfiles_log "📁 Setting up Vim configuration..."
        cp -r "$DOTFILES_DIR/.vim" "$HOME/"
    fi
    
    dotfiles_log "✅ Symlinks created successfully"
}

# =============================================================================
# Git Configuration Generation
# =============================================================================

generate_gitconfig() {
    dotfiles_log "📝 Generating platform-specific .gitconfig..."
    
    local template_path="$DOTFILES_COMMON_DIR/.gitconfig.template"
    local target_path="$HOME/.gitconfig"
    
    if [[ ! -f "$template_path" ]]; then
        dotfiles_log "⚠️  Template not found: $template_path, skipping .gitconfig generation."
        return
    fi
    
    # Check if .gitconfig already exists
    if [[ -f "$target_path" ]]; then
        dotfiles_log "📋 Existing .gitconfig found at $target_path"
        echo ""
        echo "An existing Git configuration was found:"
        echo "  Location: $target_path"
        if command -v git &> /dev/null; then
            local existing_name existing_email
            existing_name=$(git config --global user.name 2>/dev/null || echo "Not set")
            existing_email=$(git config --global user.email 2>/dev/null || echo "Not set")
            echo "  Current name: $existing_name"
            echo "  Current email: $existing_email"
        fi
        echo ""
        read -p "Do you want to overwrite the existing .gitconfig? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            dotfiles_log "✅ Keeping existing .gitconfig, skipping generation"
            return
        fi
        
        # Backup existing file
        local backup_path="${target_path}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$target_path" "$backup_path"
        dotfiles_log "📦 Backed up existing .gitconfig to $backup_path"
    fi
    
    # Determine credential helper based on platform
    local credential_helper=""
    if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        # Running in WSL
        credential_helper="manager"
        dotfiles_log "🐧 Detected WSL environment, using Git Credential Manager"
    elif [[ "$DOTFILES_OS" == "macos" ]]; then
        # Running on macOS
        credential_helper="manager"
        dotfiles_log "🍎 Detected macOS environment, using Git Credential Manager"
    elif [[ "$DOTFILES_OS" == "windows" ]]; then
        # Running on Windows
        credential_helper="manager"
        dotfiles_log "🪟 Detected Windows environment, using Git Credential Manager"
    elif [[ "$DOTFILES_OS" == "linux" ]]; then
        # Running on native Linux
        credential_helper="manager"
        dotfiles_log "🐧 Detected Linux environment, using Git Credential Manager"
    else
        # Fallback - use manager as default
        credential_helper="manager"
        dotfiles_log "❓ Unknown environment, using Git Credential Manager as default"
    fi
    
    # Prompt for Git user details
    local git_name git_email
    read -p "Enter your Git name: " git_name
    read -p "Enter your Git email: " git_email
    
    # Read template and replace placeholders
    local content
    content=$(cat "$template_path")
    content="${content//__GIT_NAME__/$git_name}"
    content="${content//__GIT_EMAIL__/$git_email}"
    content="${content//__CREDENTIAL_HELPER__/$credential_helper}"
    
    # Write to ~/.gitconfig
    echo "$content" > "$target_path"
    dotfiles_log "✅ .gitconfig created at $target_path with platform-specific credential helper"
}

# =============================================================================
# Claude Code Hooks Setup
# =============================================================================

setup_claude_hooks() {
    dotfiles_log "🤖 Setting up Claude Code hooks..."

    # Check if we're on macOS (caffeinate only works on macOS)
    if [[ "$DOTFILES_OS" != "macos" ]]; then
        dotfiles_log "⏭️  Skipping Claude Code sleep prevention hooks (macOS only)"
        return 0
    fi

    # Check if Claude Code is installed
    if ! command -v claude >/dev/null 2>&1; then
        dotfiles_log "⏭️  Claude Code not installed, skipping hooks setup"
        return 0
    fi

    # Ask user if they want to install Claude Code hooks
    read -p "Do you want to install Claude Code sleep prevention hooks? (prevents Mac from sleeping while Claude is working) (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        dotfiles_log "⏭️  Skipping Claude Code hooks setup"
        return 0
    fi

    # Create hooks directory if it doesn't exist
    local hooks_dir="$HOME/.claude/hooks"
    if [[ ! -d "$hooks_dir" ]]; then
        mkdir -p "$hooks_dir"
        dotfiles_log "📁 Created Claude hooks directory: $hooks_dir"
    fi

    # Copy hook scripts
    if [[ -f "$DOTFILES_COMMON_DIR/claude_hooks/prevent-sleep.sh" ]]; then
        cp "$DOTFILES_COMMON_DIR/claude_hooks/prevent-sleep.sh" "$hooks_dir/"
        chmod +x "$hooks_dir/prevent-sleep.sh"
        dotfiles_log "✅ Installed prevent-sleep.sh hook"
    else
        dotfiles_log "⚠️  prevent-sleep.sh not found in $DOTFILES_COMMON_DIR/claude_hooks/"
    fi

    if [[ -f "$DOTFILES_COMMON_DIR/claude_hooks/allow-sleep.sh" ]]; then
        cp "$DOTFILES_COMMON_DIR/claude_hooks/allow-sleep.sh" "$hooks_dir/"
        chmod +x "$hooks_dir/allow-sleep.sh"
        dotfiles_log "✅ Installed allow-sleep.sh hook"
    else
        dotfiles_log "⚠️  allow-sleep.sh not found in $DOTFILES_COMMON_DIR/claude_hooks/"
    fi

    # Check if .claude/settings.json exists and update it
    local settings_file="$HOME/.claude/settings.json"
    if [[ -f "$settings_file" ]]; then
        dotfiles_log "📝 Found existing Claude settings, you'll need to manually add hooks configuration"
        echo ""
        echo "Add the following to your $settings_file:"
        echo ""
        echo '  "hooks": {'
        echo '    "Stop": ['
        echo '      {'
        echo '        "hooks": ['
        echo '          {'
        echo '            "type": "command",'
        echo '            "command": "$HOME/.claude/hooks/allow-sleep.sh"'
        echo '          }'
        echo '        ]'
        echo '      }'
        echo '    ],'
        echo '    "UserPromptSubmit": ['
        echo '      {'
        echo '        "hooks": ['
        echo '          {'
        echo '            "type": "command",'
        echo '            "command": "$HOME/.claude/hooks/prevent-sleep.sh"'
        echo '          }'
        echo '        ]'
        echo '      }'
        echo '    ]'
        echo '  }'
        echo ""
    else
        dotfiles_log "💡 Claude settings not found. Hooks will be available when you configure Claude Code."
    fi

    dotfiles_log "✅ Claude Code hooks setup complete!"
}

# =============================================================================
# Agent Skills Setup
# =============================================================================
#
# Skills follow the open Agent Skills standard (https://agentskills.io), a
# directory with a SKILL.md that works across AI coding tools. Codex CLI and
# Gemini CLI read the canonical ~/.agents/skills/ location natively. Claude
# Code does not (as of writing it only reads ~/.claude/skills/, see
# https://github.com/anthropics/claude-code/issues/31005), so skills are
# mirrored there via symlink.
#
# This keeps ~/.agents/skills/ as the single source of truth: any real skill
# directory found under a tool-specific skills folder gets moved there once,
# then replaced with a symlink back. Re-running is a no-op once migrated.

setup_agent_skills() {
    local agents_skills_dir="$HOME/.agents/skills"
    local claude_skills_dir="$HOME/.claude/skills"
    local codex_skills_dir="$HOME/.codex/skills"

    dotfiles_log "🔗 Reconciling Agent Skills into $agents_skills_dir..."
    mkdir -p "$agents_skills_dir"

    # Repo-owned skills: personal ones in agent-skills/ (committed), work ones in
    # custom-*/agent-skills/ (gitignored). Link each
    # into the canonical store; the repo stays the source of truth.
    local src skill_dir skill_name
    for src in "$DOTFILES_DIR"/agent-skills "$DOTFILES_DIR"/custom-*/agent-skills; do
        [[ -d "$src" ]] || continue
        for skill_dir in "$src"/*/; do
            [[ -f "$skill_dir/SKILL.md" ]] || continue
            skill_dir="${skill_dir%/}"
            skill_name="$(basename "$skill_dir")"
            if [[ -L "$agents_skills_dir/$skill_name" ]]; then
                ln -sfn "$skill_dir" "$agents_skills_dir/$skill_name"
            elif [[ -e "$agents_skills_dir/$skill_name" ]]; then
                dotfiles_log "⚠️  $skill_name exists in $agents_skills_dir as a real dir; move it into $src to track it"
            else
                ln -s "$skill_dir" "$agents_skills_dir/$skill_name"
                dotfiles_log "✅ Linked repo skill $skill_name"
            fi
        done
    done

    # Third-party skills from agent-skills/skills.list via the skills CLI
    # (https://github.com/vercel-labs/skills). It installs into the canonical
    # store and symlinks into each agent's dir. Dangling links are cleaned first.
    local dead
    for dead in "$claude_skills_dir"/*; do
        [[ -L "$dead" && ! -e "$dead" ]] && command rm -f "$dead"
    done
    local list="$DOTFILES_DIR/agent-skills/skills.list" repo skill
    if [[ -f "$list" ]] && ! command -v npx >/dev/null 2>&1; then
        dotfiles_log "⚠️  npx not found: third-party skills in $list were NOT installed"
    fi
    if [[ -f "$list" ]] && command -v npx >/dev/null 2>&1; then
        while read -r repo skill; do
            [[ -z "$repo" || "$repo" == \#* || -e "$agents_skills_dir/$skill" ]] && continue
            DISABLE_TELEMETRY=1 npx -y skills add "$repo" -g -y -s "$skill" \
                -a claude-code -a codex -a gemini-cli -a opencode </dev/null \
                && dotfiles_log "✅ Installed $skill from $repo" \
                || dotfiles_log "⚠️  Failed to install $skill from $repo"
        done < "$list"
    fi

    # Move any real (non-symlink) skill directory under $1 into the canonical
    # store, then symlink it back. Never overwrites a canonical skill that
    # already exists under a different, possibly diverged, copy.
    _migrate_skills_into_canonical() {
        local source_dir="$1"
        local source_label="$2"
        [[ -d "$source_dir" ]] || return 0

        local entry name canonical_target
        for entry in "$source_dir"/*/; do
            [[ -e "$entry" ]] || continue
            entry="${entry%/}"
            [[ -L "$entry" ]] && continue  # already migrated
            name="$(basename "$entry")"
            [[ "$name" == "synced" && "$source_label" == "~/.claude/skills" ]] && continue  # Claude-managed cloud skill sync, not ours
            canonical_target="$agents_skills_dir/$name"

            if [[ -e "$canonical_target" ]]; then
                dotfiles_log "⚠️  Skipping $source_label/$name: '$name' already exists in $agents_skills_dir (diff and merge manually)"
                continue
            fi

            mv "$entry" "$canonical_target"
            ln -s "$canonical_target/" "$entry"
            dotfiles_log "✅ Migrated $source_label/$name -> $agents_skills_dir/$name (symlinked back)"
        done
    }

    # .system under ~/.codex/skills holds Codex's own bundled skills, not user
    # skills; the */ glob above skips it since it's a dotfile.
    _migrate_skills_into_canonical "$claude_skills_dir" "~/.claude/skills"
    _migrate_skills_into_canonical "$codex_skills_dir" "~/.codex/skills"

    # Claude Code needs an explicit symlink per skill since it doesn't read
    # ~/.agents/skills/ directly.
    mkdir -p "$claude_skills_dir"
    local entry name link_target
    for entry in "$agents_skills_dir"/*/; do
        [[ -e "$entry" ]] || continue
        entry="${entry%/}"
        name="$(basename "$entry")"
        link_target="$claude_skills_dir/$name"

        if [[ -L "$link_target" ]]; then
            continue
        elif [[ -e "$link_target" ]]; then
            dotfiles_log "⚠️  Skipping Claude link for $name: $link_target exists and isn't a symlink (diff and merge manually)"
            continue
        fi

        ln -s "$entry/" "$link_target"
        dotfiles_log "✅ Linked $link_target -> $entry"
    done

    unset -f _migrate_skills_into_canonical

    dotfiles_log "✅ Agent Skills reconciled (canonical store: $agents_skills_dir)"
}

# =============================================================================
# Global Agent Rules (commit/PR conventions)
# =============================================================================
# One AGENTS.md in the repo, symlinked for Claude (CLAUDE.md) and Codex. Claude
# Code additionally gets deterministic enforcement: attribution disabled in
# settings.json plus a PreToolUse hook that blocks attributed commits/PRs.

setup_agent_rules() {
    mkdir -p "$HOME/.claude" "$HOME/.codex"
    local merged tgt f
    merged="$(mktemp)"
    echo "<!-- generated by dev-machine-setup (setup_dotfiles.sh skills); edit the sources -->" > "$merged"
    cat "$DOTFILES_COMMON_DIR/agents/AGENTS.md" >> "$merged"
    for f in "$DOTFILES_DIR"/custom-*/agents/AGENTS.md; do
        [[ -f "$f" ]] && cat "$f" >> "$merged"
    done
    for tgt in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"; do
        # Keep any hand-written file once; our own generated files carry the marker.
        if [[ -f "$tgt" && ! -L "$tgt" ]] && ! grep -q "generated by dev-machine-setup" "$tgt"; then
            cp "$tgt" "$tgt.bak.$(date +%Y%m%d%H%M%S)"
            dotfiles_log "⚠️  Backed up existing $tgt before replacing it"
        fi
        command rm -f "$tgt"  # drop any old symlink so we never write through to the repo
        cp "$merged" "$tgt"
    done
    command rm -f "$merged"

    if ! command -v jq >/dev/null 2>&1; then
        dotfiles_log "⚠️  jq missing: Claude attribution setting and guard hook NOT installed"
        return 1
    fi
    mkdir -p "$HOME/.claude/hooks"
    cp "$DOTFILES_COMMON_DIR/claude_hooks/no-attribution.sh" "$HOME/.claude/hooks/"

    f="$HOME/.claude/settings.json"
    [[ -f "$f" ]] || echo '{}' > "$f"
    local tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/claude-settings.XXXXXX")"
    if jq '.attribution = {commit: "", pr: ""}
        | .hooks.PreToolUse = (
            ((.hooks.PreToolUse // [])
              | map(.hooks |= map(select(((.command // "") | test("no-attribution")) | not)))
              | map(select((.hooks | length) > 0)))
            + [{matcher: "Bash", hooks: [{type: "command", command: "$HOME/.claude/hooks/no-attribution.sh"}]}])' \
        "$f" > "$tmp"; then
        cat "$tmp" > "$f"  # write through, so a symlinked settings.json keeps its target
        command rm -f "$tmp"
        dotfiles_log "✅ Agent rules written; Claude attribution disabled + guard hook installed"
    else
        command rm -f "$tmp"
        dotfiles_log "⚠️  Could not update $f (invalid JSON?); attribution setting and hook NOT installed"
        return 1
    fi
}

# =============================================================================
# Development Environment Setup
# =============================================================================

setup_development_environment() {
    dotfiles_log "🔧 Setting up development environment..."
    
    # Ask user if they want to install version managers
    read -p "Do you want to install version managers (rbenv, pyenv, goenv, SDKMAN, nvm, tfswitch)? This may take a while. (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        dotfiles_log "⏭️  Skipping development environment setup"
        return 0
    fi
    
    # Run development environment setup with error handling (in subshell to isolate set -e)
    if [[ -f "$DOTFILES_COMMON_DIR/setup_dev_env.sh" ]]; then
        dotfiles_log "🚀 Installing version managers and development tools..."
        chmod +x "$DOTFILES_COMMON_DIR/setup_dev_env.sh"
        if ! (source "$DOTFILES_COMMON_DIR/setup_dev_env.sh"); then
            dotfiles_log "⚠️  Development environment setup had some issues, but continuing..."
        fi
    else
        dotfiles_log "⚠️  Development environment setup script not found, skipping"
    fi
}

# =============================================================================
# Platform-Specific Setup
# =============================================================================

run_platform_setup() {
    dotfiles_log "🔧 Running platform-specific setup for $DOTFILES_OS..."
    
    case "$DOTFILES_OS" in
        "macos")
            if [[ -f "$DOTFILES_OS_DIR/setup_macos.sh" ]]; then
                dotfiles_log "🍎 Running macOS-specific setup..."
                chmod +x "$DOTFILES_OS_DIR/setup_macos.sh"
                (source "$DOTFILES_OS_DIR/setup_macos.sh") || {
                    dotfiles_log "⚠️  macOS setup had some issues, continuing..."
                }
            else
                dotfiles_log "⚠️  macOS setup script not found, skipping platform-specific setup"
            fi
            ;;
        "linux")
            if [[ -f "$DOTFILES_OS_DIR/setup_linux.sh" ]]; then
                dotfiles_log "🐧 Running Linux-specific setup..."
                chmod +x "$DOTFILES_OS_DIR/setup_linux.sh"
                (source "$DOTFILES_OS_DIR/setup_linux.sh") || {
                    dotfiles_log "⚠️  Linux setup had some issues, continuing..."
                }
            else
                dotfiles_log "⚠️  Linux setup script not found, skipping platform-specific setup"
            fi
            ;;
        "windows")
            dotfiles_log "🪟 Windows platform detected"
            dotfiles_log "ℹ️  Windows-specific setup should be handled by PowerShell script"
            ;;
        *)
            dotfiles_log "❌ Unsupported OS: $DOTFILES_OS"
            return 1
            ;;
    esac
}

# =============================================================================
# Validation Functions
# =============================================================================

validate_dotfiles() {
    dotfiles_log "🔍 Validating dotfiles installation..."
    
    # Check if validation script exists and run it
    if [[ -f "$DOTFILES_DIR/validate.sh" ]]; then
        chmod +x "$DOTFILES_DIR/validate.sh"
        source "$DOTFILES_DIR/validate.sh"
    fi
    
    # Check if common symlinks exist
    local errors=0
    check_symlink() {
        local file="$1"
        if [[ ! -L "$file" ]]; then
            dotfiles_log "❌ Missing symlink: $file"
            ((errors++))
        else
            dotfiles_log "✅ Symlink exists: $file"
        fi
    }
    
    check_symlink "$HOME/.gitconfig"
    check_symlink "$HOME/.gitignore_global"
    check_symlink "$HOME/.vimrc"
    check_symlink "$HOME/.zshrc"
    check_symlink "$HOME/.p10k.zsh"
    
    # Run health check if available
    if command -v dotfiles-health &> /dev/null; then
        dotfiles_log "🏥 Running dotfiles health check..."
        dotfiles-health
    fi
    
    if [[ $errors -eq 0 ]]; then
        dotfiles_log "✅ Dotfiles validation passed"
        return 0
    else
        dotfiles_log "❌ Dotfiles validation failed with $errors errors"
        return 1
    fi
}

# =============================================================================
# Main Installation Function
# =============================================================================

install_dotfiles() {
    # Setup environment first (required for logging)
    setup_dotfiles_environment

    dotfiles_log "🚀 Starting dotfiles installation..."

    # Check prerequisites
    if ! check_dotfiles_prerequisites; then
        return 1
    fi

    dotfiles_log "🔧 Setting up dotfiles for $DOTFILES_OS ($DOTFILES_PLATFORM)"
    dotfiles_log "📁 Dotfiles directory: $DOTFILES_DIR"

    # Execute installation steps
    backup_existing_files
    create_symlinks
    setup_development_environment
    setup_claude_hooks
    setup_agent_skills
    setup_agent_rules

    # Generate ~/.gitconfig from platform-specific template
    generate_gitconfig

    dotfiles_log "✅ Dotfiles installation complete!"

    # Show completion message
    echo ""
    echo "📋 Next steps:"
    echo "   1. Restart your terminal or run: exec zsh"
    echo "   2. Configure Powerlevel10k by running: p10k configure"
    echo "   3. Install any additional tools specific to your workflow"
    echo ""
    echo "🔍 Platform detected: $DOTFILES_PLATFORM"
    echo "🗂️  Configuration loaded from: $DOTFILES_OS_DIR"
    echo ""
    echo "💡 Tips:"
    echo "   - Run 'reload' to reload your shell configuration"
    echo "   - Use 'zshconfig' to edit your zsh configuration"
    echo "   - Check available aliases with 'alias'"
    echo "   - Run 'dotfiles-health' to check system health"
    echo ""
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    case "${1:-install}" in
        "install"|"")
            install_dotfiles
            ;;
        "validate")
            setup_dotfiles_environment
            validate_dotfiles
            ;;
        "backup")
            setup_dotfiles_environment
            backup_existing_files
            ;;
        "skills")
            setup_dotfiles_environment
            setup_agent_skills
            setup_agent_rules
            ;;
        "--help"|"-h"|"help")
            show_help
            ;;
        *)
            echo "❌ Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

show_help() {
    cat << EOF
Dotfiles Setup Script

Usage: $0 [COMMAND]

Commands:
    install     Install dotfiles (default if no command specified)
    validate    Validate existing dotfiles installation
    backup      Backup existing configuration files
    skills      Reconcile Agent Skills into ~/.agents/skills/ (Claude/Codex/Gemini)
    help        Show this help message

Examples:
    $0                    # Install dotfiles
    $0 install           # Install dotfiles
    $0 validate          # Validate installation
    $0 backup            # Backup existing files
    $0 skills            # Reconcile Agent Skills across tools

This script can also be sourced to use individual functions:
    source $0 && install_dotfiles
EOF
}

# =============================================================================
# Script Execution - Only run main if script is executed directly
# =============================================================================

# Check if script is being executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# =============================================================================
# Exported Functions
# =============================================================================

# Export all functions for use by sourcing scripts
export -f setup_dotfiles_environment
export -f dotfiles_log
export -f check_dotfiles_prerequisites
export -f backup_existing_files
export -f create_symlinks
export -f setup_development_environment
export -f setup_agent_skills
export -f setup_agent_rules
export -f run_platform_setup
export -f validate_dotfiles
export -f install_dotfiles

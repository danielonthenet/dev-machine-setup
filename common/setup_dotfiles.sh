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
        credential_helper="[credential]
  helper = /mnt/c/Program\\\\ Files/Git/mingw64/bin/git-credential-manager.exe"
        dotfiles_log "🐧 Detected WSL environment, using Windows Git Credential Manager"
    elif [[ "$DOTFILES_OS" == "macos" ]]; then
        # Running on macOS
        credential_helper="[credential]
  helper = osxkeychain"
        dotfiles_log "🍎 Detected macOS environment, using osxkeychain"
    elif [[ "$DOTFILES_OS" == "windows" ]]; then
        # Running on Windows
        credential_helper="[credential]
	helper = manager"
        dotfiles_log "🪟 Detected Windows environment, using Git Credential Manager"
    elif [[ "$DOTFILES_OS" == "linux" ]]; then
        # Running on native Linux - use WSL credential helper as fallback
        credential_helper="[credential]
  helper = /mnt/c/Program\\\\ Files/Git/mingw64/bin/git-credential-manager.exe"
        dotfiles_log "🐧 Detected Linux environment, using Windows Git Credential Manager (fallback)"
    else
        # Fallback - no credential helper
        credential_helper="# No credential helper configured for this platform"
        dotfiles_log "❓ Unknown environment, no credential helper configured"
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
# Development Environment Setup
# =============================================================================

setup_development_environment() {
    dotfiles_log "🔧 Setting up development environment..."
    
    # Ask user if they want to install version managers
    read -p "Do you want to install version managers (rbenv, pyenv, nvm)? This may take a while and requires internet connectivity. (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        dotfiles_log "⏭️  Skipping development environment setup"
        return 0
    fi
    
    # Run development environment setup with error handling
    if [[ -f "$DOTFILES_COMMON_DIR/setup_dev_env.sh" ]]; then
        dotfiles_log "🚀 Installing version managers and development tools..."
        chmod +x "$DOTFILES_COMMON_DIR/setup_dev_env.sh"
        if ! source "$DOTFILES_COMMON_DIR/setup_dev_env.sh"; then
            dotfiles_log "⚠️  Development environment setup failed, but continuing..."
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
                source "$DOTFILES_OS_DIR/setup_macos.sh"
            else
                dotfiles_log "⚠️  macOS setup script not found, skipping platform-specific setup"
            fi
            ;;
        "linux")
            if [[ -f "$DOTFILES_OS_DIR/setup_linux.sh" ]]; then
                dotfiles_log "🐧 Running Linux-specific setup..."
                chmod +x "$DOTFILES_OS_DIR/setup_linux.sh"
                source "$DOTFILES_OS_DIR/setup_linux.sh"
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
    help        Show this help message

Examples:
    $0                    # Install dotfiles
    $0 install           # Install dotfiles  
    $0 validate          # Validate installation
    $0 backup            # Backup existing files

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
export -f run_platform_setup
export -f validate_dotfiles
export -f install_dotfiles

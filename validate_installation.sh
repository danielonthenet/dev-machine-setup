#!/bin/bash

# Installation validation script for development machine setup

echo "🔍 Validating Development Machine Installation"
echo "============================================="
echo ""

# Detect current setup
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_TYPE="$(uname -s)"

case "$OS_TYPE" in
    "Darwin") PLATFORM="macos" ;;
    "Linux") 
        if [[ -n "$WSL_DISTRO_NAME" ]]; then
            PLATFORM="wsl"
        else
            PLATFORM="linux"
        fi ;;
    *) PLATFORM="unknown" ;;
esac

echo "📋 Environment:"
echo "  Platform: $PLATFORM"
echo "  Setup Dir: $SETUP_DIR"
echo "  Home Dir: $HOME"
echo ""

# Check directory structure
echo "📁 Project Structure:"
if [[ -d "$SETUP_DIR/common" ]]; then
    echo "  ✅ common/ directory exists"
else
    echo "  ❌ common/ directory missing"
fi

if [[ -d "$SETUP_DIR/$PLATFORM" ]]; then
    echo "  ✅ $PLATFORM/ directory exists"
else
    echo "  ❌ $PLATFORM/ directory missing"
fi

if [[ -d "$SETUP_DIR/docs" ]]; then
    echo "  ✅ docs/ directory exists"
else
    echo "  ❌ docs/ directory missing"
fi
echo ""

# Check configuration files
echo "⚙️  Configuration Files:"
files=(
    "$SETUP_DIR/common/.gitconfig"
    "$SETUP_DIR/common/shared/aliases.sh"
    "$SETUP_DIR/common/shared/functions.sh"
    "$SETUP_DIR/common/shared/exports.sh"
    "$SETUP_DIR/common/shared/lazy_load.sh"
    "$SETUP_DIR/$PLATFORM/aliases.sh"
    "$SETUP_DIR/$PLATFORM/functions.sh"
    "$SETUP_DIR/$PLATFORM/exports.sh"
)

for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ✅ $(basename "$file")"
    else
        echo "  ❌ $(basename "$file") missing"
    fi
done
echo ""

# Check symlinks (if dotfiles have been installed)
echo "🔗 Symlinks (if installed):"
symlinks=(
    "$HOME/.gitconfig"
    "$HOME/.p10k.zsh"
    "$HOME/.zshrc"
)

for link in "${symlinks[@]}"; do
    if [[ -L "$link" ]]; then
        echo "  ✅ $(basename "$link") → $(readlink "$link")"
    elif [[ -f "$link" ]]; then
        echo "  ℹ️  $(basename "$link") exists (not symlinked)"
    else
        echo "  ❓ $(basename "$link") not found"
    fi
done
echo ""

# Check aliases (if loaded)
echo "🔧 Sample Aliases (if loaded):"
aliases_to_check=("ll" "la" "reload" "dotfiles-health" "dotfiles-update")
for alias_name in "${aliases_to_check[@]}"; do
    if alias "$alias_name" >/dev/null 2>&1; then
        echo "  ✅ $alias_name"
    else
        echo "  ❓ $alias_name not loaded"
    fi
done
echo ""

# Check functions (if loaded)
echo "🛠  Sample Functions (if loaded):"
functions_to_check=("dotfiles-health" "dotfiles-quick-check" "mkd")
for func_name in "${functions_to_check[@]}"; do
    if declare -f "$func_name" >/dev/null 2>&1; then
        echo "  ✅ $func_name"
    else
        echo "  ❓ $func_name not loaded"
    fi
done
echo ""

# Check modern tools
echo "🚀 Modern Tools:"
tools=("exa" "bat" "rg" "fd" "fzf" "htop" "tree")
for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✅ $tool ($(command -v "$tool"))"
    else
        echo "  ❓ $tool not installed"
    fi
done
echo ""

# Check HashiCorp tools
echo "🔐 HashiCorp Tools:"
hashicorp_tools=("consul" "vault")
for tool in "${hashicorp_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        version_output=$("$tool" version 2>/dev/null | head -n1 || echo "version unavailable")
        echo "  ✅ $tool ($version_output)"
    else
        echo "  ❓ $tool not installed"
    fi
done
echo ""

# Platform-specific checks
echo "🎯 Platform-Specific Checks:"
case "$PLATFORM" in
    "macos")
        if command -v brew >/dev/null 2>&1; then
            echo "  ✅ Homebrew installed"
        else
            echo "  ❌ Homebrew not found"
        fi
        
        # Check Oh My Zsh
        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            echo "  ✅ Oh My Zsh installed"
        else
            echo "  ❓ Oh My Zsh not found"
        fi
        
        # Check Powerlevel10k
        if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
            echo "  ✅ Powerlevel10k theme installed"
        else
            echo "  ❓ Powerlevel10k theme not found"
        fi
        ;;
        
    "wsl"|"linux")
        if command -v apt >/dev/null 2>&1; then
            echo "  ✅ APT package manager available"
        elif command -v yum >/dev/null 2>&1; then
            echo "  ✅ YUM package manager available"
        else
            echo "  ❓ Package manager not found"
        fi
        
        if [[ -n "$WSL_DISTRO_NAME" ]]; then
            echo "  ✅ WSL environment detected: $WSL_DISTRO_NAME"
        else
            echo "  ✅ Native Linux environment"
        fi
        
        # Check Oh My Zsh
        if [[ -d "$HOME/.oh-my-zsh" ]]; then
            echo "  ✅ Oh My Zsh installed"
        else
            echo "  ❓ Oh My Zsh not found"
        fi
        ;;
        
    *)
        echo "  ❓ Unknown platform: $OS_TYPE"
        ;;
esac
echo ""

# Check version managers
echo "🔧 Version Managers:"
version_managers=("nvm" "pyenv" "rbenv" "g" "tfswitch")
for vm in "${version_managers[@]}"; do
    if command -v "$vm" >/dev/null 2>&1; then
        echo "  ✅ $vm installed"
    elif [[ -d "$HOME/.${vm}" ]] || [[ -d "$HOME/.${vm}rc" ]] || [[ -f "$HOME/.${vm}rc" ]]; then
        echo "  ✅ $vm detected (may need shell reload)"
    else
        echo "  ❓ $vm not found"
    fi
done

# Run version manager validation if available
if [[ -f "$SETUP_DIR/common/validate_version_managers.sh" ]]; then
    echo "  Running detailed version manager validation..."
    source "$SETUP_DIR/common/validate_version_managers.sh" 2>/dev/null || echo "  ℹ️  Version manager validation needs shell setup"
else
    echo "  ❌ Version manager validation script not found"
fi
echo ""

echo "🎉 Installation Validation Complete!"
echo ""
echo "💡 Next Steps:"
echo "  - Run 'exec zsh' or restart terminal to reload shell"
echo "  - Configure Powerlevel10k with 'p10k configure'"
echo "  - Test version managers: 'nvm --version', 'pyenv --version'"
echo "  - Run 'dotfiles-health' for comprehensive runtime check"
echo "  - Check installation logs in ~/.dev-machine-setup.log"

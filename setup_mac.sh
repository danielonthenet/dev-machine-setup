#!/bin/bash
# macOS Development Machine Setup
# Complete automation for setting up a development environment on macOS

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Get script directory
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$HOME/.dev-machine-setup.log"
}

# Welcome message
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    macOS Dev Machine Setup                  ║"
echo "║              Complete Development Environment                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

log "🍎 Starting macOS development machine setup..."
log "📁 Setup directory: $SETUP_DIR"

# Check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${RED}❌ This script is for macOS only. Current OS: $(uname)${NC}"
        exit 1
    fi
    
    # Check macOS version
    local macos_version=$(sw_vers -productVersion)
    log "macOS Version: $macos_version"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Please do not run this script as root${NC}"
        exit 1
    fi
    
    # Check internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}❌ No internet connection detected${NC}"
        exit 1
    fi
    
    # Check available disk space (at least 5GB)
    local available_space=$(df -h / | awk 'NR==2{print $4}' | sed 's/G.*//')
    if [[ $available_space -lt 5 ]]; then
        echo -e "${YELLOW}⚠️  Warning: Low disk space (${available_space}GB available)${NC}"
        read -p "Continue anyway? [y/N]: " continue_setup
        if [[ ! "$continue_setup" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    log "✅ Prerequisites check passed"
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    log "🔨 Installing Xcode Command Line Tools..."
    
    if xcode-select -p &> /dev/null; then
        log "✅ Xcode Command Line Tools already installed"
        return 0
    fi
    
    echo -e "${BLUE}Installing Xcode Command Line Tools...${NC}"
    echo "This may take several minutes and will require your password."
    
    # Install Xcode Command Line Tools
    xcode-select --install 2>/dev/null || true
    
    # Wait for installation to complete
    echo "Waiting for Xcode Command Line Tools installation to complete..."
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
    
    log "✅ Xcode Command Line Tools installed successfully"
}

# Install Homebrew
install_homebrew() {
    log "🍺 Setting up Homebrew..."
    
    if command -v brew &> /dev/null; then
        log "✅ Homebrew already installed"
        log "Updating Homebrew..."
        brew update
        return 0
    fi
    
    echo -e "${BLUE}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    log "✅ Homebrew installed successfully"
}

# Install macOS packages
install_packages() {
    log "📦 Installing macOS packages..."
    
    if [[ -f "$SETUP_DIR/macos/setup_macos.sh" ]]; then
        echo -e "${BLUE}Running macOS-specific setup...${NC}"
        chmod +x "$SETUP_DIR/macos/setup_macos.sh"
        # Export DOTFILES_DIR for the macOS setup script
        export DOTFILES_DIR="$SETUP_DIR"
        source "$SETUP_DIR/macos/setup_macos.sh"
    else
        log "⚠️  macOS setup script not found, continuing with basic setup"
    fi
}

# Setup dotfiles and development environment
setup_dotfiles() {
    log "⚙️  Setting up dotfiles and development environment..."
    
    echo -e "${BLUE}Configuring shell and development tools...${NC}"
    
    # Execute the dotfiles setup script
    if [[ -f "$SETUP_DIR/common/setup_dotfiles.sh" ]]; then
        chmod +x "$SETUP_DIR/common/setup_dotfiles.sh"
        "$SETUP_DIR/common/setup_dotfiles.sh" install
    else
        log "❌ Shared dotfiles library not found"
        return 1
    fi
    
    log "✅ Dotfiles and development environment configured"
}

# Configure macOS system preferences
configure_system() {
    log "🎛️  Configuring macOS system preferences..."
    
    # Apply macOS-specific configurations if available
    if [[ -f "$SETUP_DIR/macos/dotfiles/.osx" ]]; then
        echo -e "${BLUE}Applying macOS system preferences...${NC}"
        chmod +x "$SETUP_DIR/macos/dotfiles/.osx"
        source "$SETUP_DIR/macos/dotfiles/.osx"
        log "✅ macOS system preferences applied"
    else
        log "ℹ️  No macOS system preferences file found, skipping"
    fi
}

# Post-installation validation
validate_setup() {
    log "🔍 Validating installation..."
    
    echo -e "${BLUE}Running validation checks...${NC}"
    
    if [[ -f "$SETUP_DIR/validate.sh" ]]; then
        chmod +x "$SETUP_DIR/validate.sh"
        source "$SETUP_DIR/validate.sh"
    fi
    
    # Quick health check
    if command -v dotfiles-health &> /dev/null; then
        echo ""
        echo -e "${BLUE}Running dotfiles health check...${NC}"
        dotfiles-health
    fi
}

# Main installation flow
main() {
    # Show setup options
    echo -e "${YELLOW}🚀 macOS Development Machine Setup Options:${NC}"
    echo "1) Full setup (recommended for new machines)"
    echo "2) Dotfiles only (skip system packages)"
    echo "3) System packages only (skip dotfiles)"
    echo "4) Custom setup (choose components)"
    echo "5) Exit"
    echo ""
    
    read -p "Choose an option [1-5]: " setup_choice
    
    case $setup_choice in
        1)
            log "Full macOS development machine setup selected"
            check_prerequisites
            install_xcode_tools
            install_homebrew
            install_packages
            setup_dotfiles
            configure_system
            validate_setup
            ;;
        2)
            log "Dotfiles-only setup selected"
            check_prerequisites
            setup_dotfiles
            validate_setup
            ;;
        3)
            log "System packages-only setup selected"
            check_prerequisites
            install_xcode_tools
            install_homebrew
            install_packages
            configure_system
            ;;
        4)
            echo ""
            echo -e "${YELLOW}Custom Setup - Select components:${NC}"
            
            read -p "Install Xcode Command Line Tools? [Y/n]: " install_xcode
            read -p "Install/Update Homebrew? [Y/n]: " install_brew
            read -p "Install system packages? [Y/n]: " install_pkgs
            read -p "Setup dotfiles? [Y/n]: " setup_dots
            read -p "Configure system preferences? [Y/n]: " config_sys
            
            check_prerequisites
            
            [[ ! "$install_xcode" =~ ^[Nn]$ ]] && install_xcode_tools
            [[ ! "$install_brew" =~ ^[Nn]$ ]] && install_homebrew
            [[ ! "$install_pkgs" =~ ^[Nn]$ ]] && install_packages
            [[ ! "$setup_dots" =~ ^[Nn]$ ]] && setup_dotfiles
            [[ ! "$config_sys" =~ ^[Nn]$ ]] && configure_system
            
            validate_setup
            ;;
        5)
            log "Setup cancelled by user"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            exit 1
            ;;
    esac
    
    # Success message
    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 Setup Complete! 🎉                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${BLUE}📋 Next steps:${NC}"
    echo "   1. Restart your terminal or run: exec zsh"
    echo "   2. Configure any remaining personal preferences"
    echo "   3. Run 'dotfiles-health' to verify everything is working"
    echo ""
    echo -e "${BLUE}📜 Setup log saved to: $HOME/.dev-machine-setup.log${NC}"
    echo -e "${BLUE}🔗 Documentation: README.md and QUICK_START.md${NC}"
    echo ""
    
    log "🎉 macOS development machine setup completed successfully!"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

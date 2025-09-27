#!/bin/bash

# =============================================================================
# Linux Development Machine Setup
# =============================================================================
# 
# This script sets up a complete Linux development environment with:
# - Essential packages and development tools
# - Version managers for multiple programming languages
# - Dotfiles configuration with Zsh and Powerlevel10k
# - Security hardening and system optimization
#
# Supported distributions: Ubuntu, Debian, CentOS, RHEL, Fedora, Arch Linux
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/danielonthenet/dev-machine-setup/main/setup_linux.sh | bash
#   or
#   ./setup_linux.sh
#
# =============================================================================

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Script configuration
readonly SCRIPT_NAME="Linux Dev Machine Setup"
readonly SCRIPT_VERSION="1.0.0"
readonly LOG_FILE="$HOME/.setup-linux.log"
readonly DOTFILES_REPO="https://github.com/danielonthenet/dev-machine-setup.git"
# DOTFILES_DIR will be set dynamically in setup_dotfiles function

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log_error "$1"
    exit 1
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    # Add any cleanup operations here
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Display header
display_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          🐧 Linux Development Setup                          ║"
    echo "║                                                                              ║"
    echo "║  This script will set up your Linux machine for development work with:      ║"
    echo "║  • Essential packages and development tools                                  ║"
    echo "║  • Version managers (rbenv, pyenv, nvm, g, tfswitch)                       ║"
    echo "║  • Zsh with Powerlevel10k theme                                            ║"
    echo "║  • Git configuration and dotfiles                                           ║"
    echo "║  • Security hardening                                                       ║"
    echo "║                                                                              ║"
    echo "║  Version: $SCRIPT_VERSION                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO="$ID"
        DISTRO_VERSION="$VERSION_ID"
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO="rhel"
        DISTRO_VERSION=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | head -1)
    elif [[ -f /etc/arch-release ]]; then
        DISTRO="arch"
        DISTRO_VERSION="rolling"
    else
        error_exit "Unable to detect Linux distribution"
    fi
    
    log_info "Detected Linux distribution: $DISTRO $DISTRO_VERSION"
    export DISTRO DISTRO_VERSION
}

# Check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    # Check if running as root (not recommended)
    if [[ $EUID -eq 0 ]]; then
        log_warn "Running as root is not recommended for security reasons"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        error_exit "No internet connection detected"
    fi
    
    # Check available disk space (at least 2GB)
    available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 2097152 ]]; then
        log_warn "Less than 2GB of free space available"
    fi
    
    log_success "Prerequisites check passed"
}

# Get package manager and install command
get_package_manager() {
    case "$DISTRO" in
        ubuntu|debian)
            PKG_MANAGER="apt"
            INSTALL_CMD="sudo apt update && sudo apt install -y"
            UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                PKG_MANAGER="dnf"
                INSTALL_CMD="sudo dnf install -y"
                UPDATE_CMD="sudo dnf update -y"
            else
                PKG_MANAGER="yum"
                INSTALL_CMD="sudo yum install -y"
                UPDATE_CMD="sudo yum update -y"
            fi
            ;;
        arch|manjaro)
            PKG_MANAGER="pacman"
            INSTALL_CMD="sudo pacman -S --noconfirm"
            UPDATE_CMD="sudo pacman -Syu --noconfirm"
            ;;
        *)
            error_exit "Unsupported distribution: $DISTRO"
            ;;
    esac
    
    log_info "Using package manager: $PKG_MANAGER"
    export PKG_MANAGER INSTALL_CMD UPDATE_CMD
}

# Update system packages
update_system() {
    log "📦 Updating system packages..."
    eval "$UPDATE_CMD"
    log_success "System packages updated"
}

# Install essential packages
install_essential_packages() {
    log "🔧 Installing essential packages..."
    
    local packages=""
    case "$DISTRO" in
        ubuntu|debian)
            packages="curl wget git vim zsh build-essential software-properties-common apt-transport-https ca-certificates gnupg lsb-release unzip tree htop neofetch jq"
            ;;
        centos|rhel|fedora)
            packages="curl wget git vim zsh gcc gcc-c++ make openssl-devel zlib-devel readline-devel sqlite-devel unzip tree htop neofetch jq"
            ;;
        arch|manjaro)
            packages="curl wget git vim zsh base-devel unzip tree htop neofetch jq"
            ;;
    esac
    
    eval "$INSTALL_CMD $packages"
    log_success "Essential packages installed"
}

# Install development tools
install_dev_tools() {
    log "⚒️  Installing development tools..."
    
    local dev_packages=""
    case "$DISTRO" in
        ubuntu|debian)
            dev_packages="nodejs npm python3 python3-pip ruby golang-go podman podman-compose"
            ;;
        centos|rhel|fedora)
            dev_packages="nodejs npm python3 python3-pip ruby golang podman podman-compose"
            ;;
        arch|manjaro)
            dev_packages="nodejs npm python python-pip ruby go podman podman-compose"
            ;;
    esac
    
    eval "$INSTALL_CMD $dev_packages"
    
    log_success "Development tools installed"
}

# Setup Zsh and Oh My Zsh
setup_zsh() {
    log "🐚 Setting up Zsh and Oh My Zsh..."
    
    # Install Zsh if not already installed
    if ! command -v zsh &> /dev/null; then
        case "$DISTRO" in
            ubuntu|debian)
                sudo apt install -y zsh
                ;;
            centos|rhel|fedora)
                sudo ${PKG_MANAGER} install -y zsh
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm zsh
                ;;
        esac
    fi
    
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install Powerlevel10k theme
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    fi
    
    # Install useful plugins
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    # zsh-autosuggestions
    if [[ ! -d "$plugins_dir/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$plugins_dir/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"
    fi
    
    # Change default shell to zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        chsh -s "$(which zsh)"
        log_info "Default shell changed to Zsh (restart required)"
    fi
    
    log_success "Zsh and Oh My Zsh setup complete"
}

# Clone and setup dotfiles
setup_dotfiles() {
    log "📁 Setting up dotfiles..."
    
    # Get the script directory (current repository)
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Use the current repository as the dotfiles directory
    DOTFILES_DIR="$script_dir"
    
    log_info "Using local repository as dotfiles source: $DOTFILES_DIR"
    
    # Run the dotfiles installation using shared library
    cd "$DOTFILES_DIR"
    if [[ -f "common/setup_dotfiles.sh" ]]; then
        chmod +x "common/setup_dotfiles.sh"
        "./common/setup_dotfiles.sh" install
    else
        error_exit "Shared dotfiles library not found: common/setup_dotfiles.sh"
    fi
    
    log_success "Dotfiles setup complete"
}

# Security hardening
setup_security() {
    log "🔐 Applying security hardening..."
    
    # Install and configure fail2ban (if available)
    case "$DISTRO" in
        ubuntu|debian)
            if ! dpkg -l | grep -q fail2ban; then
                sudo apt install -y fail2ban
                sudo systemctl enable fail2ban
                sudo systemctl start fail2ban
            fi
            ;;
        centos|rhel|fedora)
            if ! rpm -q fail2ban &> /dev/null; then
                sudo ${PKG_MANAGER} install -y fail2ban
                sudo systemctl enable fail2ban
                sudo systemctl start fail2ban
            fi
            ;;
    esac
    
    # Configure automatic security updates (Ubuntu/Debian)
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
        sudo apt install -y unattended-upgrades
        echo 'Unattended-Upgrade::Automatic-Reboot "false";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades
    fi
    
    # Set up UFW firewall (Ubuntu/Debian)
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]] && command -v ufw &> /dev/null; then
        sudo ufw --force enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
    fi
    
    log_success "Basic security hardening applied"
}

# Performance optimizations
optimize_performance() {
    log "⚡ Applying performance optimizations..."
    
    # Configure swappiness
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
    
    # Configure file system settings
    echo 'vm.dirty_ratio=15' | sudo tee -a /etc/sysctl.conf
    echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.conf
    
    # Apply sysctl settings
    sudo sysctl -p
    
    log_success "Performance optimizations applied"
}

# Final setup and recommendations
final_setup() {
    log "🎯 Completing final setup..."
    
    # Create common development directories
    mkdir -p "$HOME/Projects"
    mkdir -p "$HOME/Scripts"
    
    # Git configuration will be handled by the dotfiles setup using platform-specific templates
    
    log_success "Final setup complete"
}

# Display completion message
display_completion() {
    echo
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                            🎉 Setup Complete! 🎉                            ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}Your Linux development machine is now ready!${NC}"
    echo
    echo -e "${WHITE}Next Steps:${NC}"
    echo -e "${YELLOW}  1.${NC} Switch to Zsh now: ${CYAN}exec zsh${NC} ${WHITE}(your new default shell)${NC}"
    echo -e "${YELLOW}  2.${NC} Configure Powerlevel10k: ${CYAN}p10k configure${NC}"
    echo -e "${YELLOW}  3.${NC} Test your setup: ${CYAN}dotfiles-health${NC}"
    echo -e "${YELLOW}  4.${NC} Install additional tools as needed"
    echo
    echo -e "${WHITE}Useful Commands:${NC}"
    echo -e "${CYAN}  reload${NC}           - Reload shell configuration"
    echo -e "${CYAN}  zshconfig${NC}        - Edit Zsh configuration"
    echo -e "${CYAN}  dotfiles-health${NC}  - Check system health"
    echo -e "${CYAN}  update-dotfiles${NC}  - Update dotfiles from repository"
    echo
    echo -e "${WHITE}Log File:${NC} ${CYAN}$LOG_FILE${NC}"
    echo
}

# Main execution
main() {
    # Initialize logging
    touch "$LOG_FILE"
    log "Starting $SCRIPT_NAME v$SCRIPT_VERSION"
    
    # Run setup steps
    display_header
    detect_distro
    check_prerequisites
    get_package_manager
    
    echo -e "${YELLOW}This script will modify your system. Continue? (y/N):${NC} "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled by user"
        exit 0
    fi
    
    update_system
    install_essential_packages
    install_dev_tools
    setup_zsh
    setup_dotfiles
    setup_security
    optimize_performance
    final_setup
    display_completion
    
    log "Setup completed successfully!"
}

# Run main function
main "$@"

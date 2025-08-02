#!/bin/bash
# Package Lists for Linux/WSL Setup

# Essential packages (always install)
ESSENTIAL_PACKAGES=(
    "zsh"
    "git"
    "curl"
    "wget"
    "vim"
    "build-essential"
    "software-properties-common"
    "apt-transport-https"
    "ca-certificates"
    "gnupg"
    "lsb-release"
)

# Modern CLI tools  
CLI_PACKAGES=(
    "bat"
    "ripgrep"
    "fd-find"
    "fzf"
    "htop"
    "tree"
    "jq"
    "unzip"
    "zip"
    "ncdu"
)

# Development tools
DEV_PACKAGES=(
    "nodejs"
    "npm"
    "podman"
    "podman-compose"
    "git-lfs"
)

# Snap packages
SNAP_PACKAGES=(
    "code --classic"
)

# Function to install essential packages
install_essential_packages() {
    echo "📦 Installing essential packages..."
    sudo apt update
    for package in "${ESSENTIAL_PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            echo "Installing $package..."
            sudo apt install -y "$package"
        fi
    done
}

# Function to install CLI tools
install_cli_packages() {
    echo "⚙️ Installing modern CLI tools..."
    for package in "${CLI_PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            echo "Installing $package..."
            sudo apt install -y "$package"
        fi
    done
    
    # Create symlink for bat if needed
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        mkdir -p ~/.local/bin
        ln -s /usr/bin/batcat ~/.local/bin/bat
    fi
    
    # Install eza if not available
    if ! command -v eza >/dev/null 2>&1; then
        if command -v cargo >/dev/null 2>&1; then
            cargo install eza
        fi
    fi
}

# Function to install development packages
install_dev_packages() {
    echo "🔧 Installing development tools..."
    for package in "${DEV_PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            echo "Installing $package..."
            sudo apt install -y "$package"
        fi
    done
}

# Function to install snap packages
install_snap_packages() {
    echo "📱 Installing snap packages..."
    for package in "${SNAP_PACKAGES[@]}"; do
        if ! snap list | grep -q "$(echo $package | cut -d' ' -f1)"; then
            echo "Installing $package..."
            sudo snap install $package
        fi
    done
}

# Interactive installation function
interactive_install() {
    echo "Choose installation option:"
    echo "1) Essential only (system packages + CLI tools)"
    echo "2) Full development setup (includes dev tools)"
    echo "3) Everything (essential + dev + snap packages)"
    echo "4) Custom selection"
    
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            install_essential_packages
            install_cli_packages
            ;;
        2)
            install_essential_packages
            install_cli_packages
            install_dev_packages
            ;;
        3)
            install_essential_packages
            install_cli_packages
            install_dev_packages
            install_snap_packages
            ;;
        4)
            echo "Custom installation options:"
            read -p "Install essential packages? (y/n): " install_essential
            read -p "Install CLI tools? (y/n): " install_cli
            read -p "Install development tools? (y/n): " install_dev
            read -p "Install snap packages? (y/n): " install_snap
            
            [[ $install_essential == "y" ]] && install_essential_packages
            [[ $install_cli == "y" ]] && install_cli_packages
            [[ $install_dev == "y" ]] && install_dev_packages
            [[ $install_snap == "y" ]] && install_snap_packages
            ;;
        *)
            echo "Invalid choice. Installing essential packages only."
            install_essential_packages
            install_cli_packages
            ;;
    esac
}

# Run interactive install if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    interactive_install
fi

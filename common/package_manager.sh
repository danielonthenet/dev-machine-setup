#!/bin/bash
# Comprehensive Package Management Script

echo "📦 Package Management Utility"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Install development packages
install_dev_packages() {
    echo -e "${BLUE}💻 Installing development packages...${NC}"
    
    # Programming languages and runtimes
    dev_packages=(
        "node"
        "python@3.11"
        "go"
        "rust"
        "java"
        "php"
        "ruby"
        "elixir"
        "kotlin"
        "scala"
        "swift"
    )
    
    for package in "${dev_packages[@]}"; do
        if ! brew list "$package" >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $package...${NC}"
            brew install "$package"
        else
            echo -e "${GREEN}✅ $package already installed${NC}"
        fi
    done
}

# Install DevOps tools
install_devops_packages() {
    echo -e "${BLUE}🔧 Installing DevOps packages...${NC}"
    
    devops_packages=(
        "podman"
        "podman-compose"
        "kubernetes-cli"
        "helm"
        "terraform"
        "ansible"
        "vault"
        "consul"
        "packer"
        "vagrant"
        "minikube"
        "istioctl"
        "k9s"
        "kubectx"
        "kustomize"
    )
    
    for package in "${devops_packages[@]}"; do
        if ! brew list "$package" >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $package...${NC}"
            brew install "$package"
        else
            echo -e "${GREEN}✅ $package already installed${NC}"
        fi
    done
}

# Install cloud CLI tools
install_cloud_packages() {
    echo -e "${BLUE}☁️ Installing cloud CLI tools...${NC}"
    
    cloud_packages=(
        "awscli"
        "azure-cli"
        "google-cloud-sdk"
        "firebase-cli"
        "vercel-cli"
        "netlify-cli"
        "heroku/brew/heroku"
        "digitalocean/doctl/doctl"
    )
    
    for package in "${cloud_packages[@]}"; do
        package_name=$(basename "$package")
        if ! brew list "$package_name" >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $package...${NC}"
            brew install "$package"
        else
            echo -e "${GREEN}✅ $package_name already installed${NC}"
        fi
    done
}

# Install database tools
install_database_packages() {
    echo -e "${BLUE}🗄️ Installing database tools...${NC}"
    
    db_packages=(
        "mysql"
        "postgresql"
        "redis"
        "mongodb-community"
        "sqlite"
        "mycli"
        "pgcli"
        "redis-cli"
    )
    
    # Add MongoDB tap
    brew tap mongodb/brew
    
    for package in "${db_packages[@]}"; do
        if ! brew list "$package" >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $package...${NC}"
            brew install "$package"
        else
            echo -e "${GREEN}✅ $package already installed${NC}"
        fi
    done
}

# Install productivity applications
install_productivity_apps() {
    echo -e "${BLUE}🚀 Installing productivity applications...${NC}"
    
    productivity_apps=(
        "visual-studio-code"
        "jetbrains-toolbox"
        "iterm2"
        "postman"
        "insomnia"
        "dbeaver-community"
        "sequel-pro"
        "mongodb-compass"
        "robo-3t"
        "github-desktop"
        "sourcetree"
        "tower"
        "fork"
        "sublime-text"
        "atom"
        "vim"
        "neovim"
    )
    
    for app in "${productivity_apps[@]}"; do
        if ! brew list --cask "$app" >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $app...${NC}"
            brew install --cask "$app" 2>/dev/null || echo -e "${RED}Failed to install $app${NC}"
        else
            echo -e "${GREEN}✅ $app already installed${NC}"
        fi
    done
}

# Install communication and collaboration apps
install_communication_apps() {
    echo -e "${BLUE}💬 Installing communication applications...${NC}"
    
    comm_apps=(
        "slack"
        "discord"
        "zoom"
        "microsoft-teams"
        "skype"
        "whatsapp"
        "signal"
    )
    
    for app in "${comm_apps[@]}"; do
        if ! brew list --cask "$app" >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $app...${NC}"
            brew install --cask "$app" 2>/dev/null || echo -e "${RED}Failed to install $app${NC}"
        else
            echo -e "${GREEN}✅ $app already installed${NC}"
        fi
    done
}

# Install security tools
install_security_packages() {
    echo -e "${BLUE}🔒 Installing security tools...${NC}"
    
    security_packages=(
        "1password"
        "1password-cli"
        "bitwarden"
        "keybase"
        "gpg-suite"
        "wireshark"
        "nmap"
        "openssl"
        "gnupg"
        "pass"
    )
    
    for package in "${security_packages[@]}"; do
        # Try as cask first, then as formula
        if ! brew list --cask "$package" >/dev/null 2>&1 && ! brew list "$package" >/dev/null 2>&1; then
            echo -e "${YELLOW}Installing $package...${NC}"
            brew install --cask "$package" 2>/dev/null || brew install "$package" 2>/dev/null || echo -e "${RED}Failed to install $package${NC}"
        else
            echo -e "${GREEN}✅ $package already installed${NC}"
        fi
    done
}

# Show installed packages
show_installed() {
    echo -e "${BLUE}📋 Installed packages:${NC}"
    echo ""
    echo -e "${YELLOW}Homebrew Formulae:${NC}"
    brew list --formula | column
    echo ""
    echo -e "${YELLOW}Homebrew Casks:${NC}"
    brew list --cask | column
}

# Cleanup packages
cleanup_packages() {
    echo -e "${BLUE}🧹 Cleaning up packages...${NC}"
    brew cleanup
    brew autoremove
    brew doctor
}

# Update all packages
update_packages() {
    echo -e "${BLUE}🔄 Updating all packages...${NC}"
    brew update
    brew upgrade
    brew cleanup
}

# Main menu
show_menu() {
    echo ""
    echo -e "${BLUE}📦 Package Management Options:${NC}"
    echo "1) Install development packages"
    echo "2) Install DevOps tools"
    echo "3) Install cloud CLI tools"
    echo "4) Install database tools"
    echo "5) Install productivity apps"
    echo "6) Install communication apps"
    echo "7) Install security tools"
    echo "8) Install everything"
    echo "9) Show installed packages"
    echo "10) Update all packages"
    echo "11) Cleanup packages"
    echo "0) Exit"
    echo ""
}

# Main execution
case "${1:-menu}" in
    "dev")
        install_dev_packages
        ;;
    "devops")
        install_devops_packages
        ;;
    "cloud")
        install_cloud_packages
        ;;
    "database")
        install_database_packages
        ;;
    "productivity")
        install_productivity_apps
        ;;
    "communication")
        install_communication_apps
        ;;
    "security")
        install_security_packages
        ;;
    "all")
        install_dev_packages
        install_devops_packages
        install_cloud_packages
        install_database_packages
        install_productivity_apps
        install_communication_apps
        install_security_packages
        ;;
    "list")
        show_installed
        ;;
    "update")
        update_packages
        ;;
    "cleanup")
        cleanup_packages
        ;;
    "menu")
        while true; do
            show_menu
            read -p "Choose an option: " choice
            case $choice in
                1) install_dev_packages ;;
                2) install_devops_packages ;;
                3) install_cloud_packages ;;
                4) install_database_packages ;;
                5) install_productivity_apps ;;
                6) install_communication_apps ;;
                7) install_security_packages ;;
                8) install_dev_packages; install_devops_packages; install_cloud_packages; install_database_packages; install_productivity_apps; install_communication_apps; install_security_packages ;;
                9) show_installed ;;
                10) update_packages ;;
                11) cleanup_packages ;;
                0) break ;;
                *) echo -e "${RED}Invalid option${NC}" ;;
            esac
        done
        ;;
    *)
        echo "Usage: $0 {dev|devops|cloud|database|productivity|communication|security|all|list|update|cleanup|menu}"
        ;;
esac

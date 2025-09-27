#!/bin/bash
# Package Lists for macOS Setup

# Essential packages (always install)
ESSENTIAL_PACKAGES=(
    "git"
    "curl" 
    "wget"
    "vim"
    "zsh"
)

# Modern CLI tools
CLI_PACKAGES=(
    "bat"
    "eza" 
    "ripgrep"
    "fd"
    "fzf"
    "dust"
    "duf"
    "htop"
    "procs"
    "autojump"
    "prettyping"
    "ncdu"
    "tree"
    "jq"
    "yq"
    "httpie"
    "tldr"
)

# Development tools
DEV_PACKAGES=(
    "git-lfs"
    "gh"
    "node"
    "nvm"
    "rbenv"
    "ruby-build"
    "pyenv"
    "podman"
    "podman-compose"
    "kubernetes-cli"
    "helm"
    "awscli"
    "azure-cli"
    "warrensbox/tap/tfswitch"
)

# Essential GUI Applications
ESSENTIAL_CASK_APPS=(
    "visual-studio-code"
    "iterm2"
    "podman-desktop"
    "google-chrome"
    "firefox"
    "rectangle"
    "the-unarchiver"
    "joplin"
    "google-drive"
    "itsycal"
)

# Development GUI Applications
DEV_CASK_APPS=(
    "gcloud-cli"
    "postman"
    "dbeaver-community"
    "github-desktop"
    "wireshark"
)

# Communication & Productivity Applications
COMM_CASK_APPS=(
    "slack"
    # "zoom"
)

# Optional Applications (install selectively)
OPTIONAL_CASK_APPS=(
    "brave-browser"
    "karabiner-elements"
    "bartender"
    "stats"
    "handbrake"
    "vlc"
)

# Fonts
FONTS=(
    "font-meslo-lg-nerd-font"
    "font-fira-code-nerd-font"
    "font-jetbrains-mono-nerd-font"
    "font-source-code-pro"
)

# Function to install CLI packages
install_cli_packages() {
    echo "🔧 Installing CLI tools..."
    for package in "${CLI_PACKAGES[@]}" "${DEV_PACKAGES[@]}"; do
        if ! brew list "$package" >/dev/null 2>&1; then
            echo "Installing $package..."
            brew install "$package"
        else
            echo "✅ $package already installed"
        fi
    done
}

# Function to install essential GUI applications
install_essential_apps() {
    echo "📱 Installing essential GUI applications..."
    for app in "${ESSENTIAL_CASK_APPS[@]}"; do
        if ! brew list --cask "$app" >/dev/null 2>&1; then
            echo "Installing $app..."
            brew install --cask "$app" 2>/dev/null || echo "Warning: Failed to install $app"
        else
            echo "✅ $app already installed"
        fi
    done
}

# Function to install development applications
install_dev_apps() {
    echo "💻 Installing development applications..."
    for app in "${DEV_CASK_APPS[@]}"; do
        if ! brew list --cask "$app" >/dev/null 2>&1; then
            echo "Installing $app..."
            brew install --cask "$app" 2>/dev/null || echo "Warning: Failed to install $app"
        else
            echo "✅ $app already installed"
        fi
    done
}

# Function to install communication applications
install_comm_apps() {
    echo "💬 Installing communication & productivity applications..."
    for app in "${COMM_CASK_APPS[@]}"; do
        if ! brew list --cask "$app" >/dev/null 2>&1; then
            echo "Installing $app..."
            brew install --cask "$app" 2>/dev/null || echo "Warning: Failed to install $app"
        else
            echo "✅ $app already installed"
        fi
    done
}

# Function to install optional applications (with user prompt)
install_optional_apps() {
    echo "🔍 Optional applications available:"
    for app in "${OPTIONAL_CASK_APPS[@]}"; do
        if ! brew list --cask "$app" >/dev/null 2>&1; then
            read -p "Install $app? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                brew install --cask "$app" 2>/dev/null || echo "Warning: Failed to install $app"
            fi
        else
            echo "✅ $app already installed"
        fi
    done
}

# Function to install fonts
install_fonts() {
    echo "🔤 Installing fonts..."
    brew tap homebrew/cask-fonts 2>/dev/null
    for font in "${FONTS[@]}"; do
        if ! brew list --cask "$font" >/dev/null 2>&1; then
            echo "Installing $font..."
            brew install --cask "$font" 2>/dev/null || echo "Warning: Failed to install $font"
        else
            echo "✅ $font already installed"
        fi
    done
}

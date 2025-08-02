#!/bin/bash
# Linux/WSL-specific setup script

echo "🐧 Setting up Linux/WSL environment..."

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load package lists and install packages
echo "📦 Installing packages..."
source "$DOTFILES_DIR/linux/packages.sh"

# Run interactive package installation
interactive_install

# Install oh-my-zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k theme
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Install zsh plugins
echo "Installing zsh plugins..."
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# Install modern CLI tools
echo "Installing modern CLI tools..."

# Install bat
if ! command -v bat >/dev/null 2>&1; then
    echo "Installing bat..."
    sudo apt install -y bat
    # Create symlink if batcat is installed instead of bat
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        mkdir -p ~/.local/bin
        ln -s /usr/bin/batcat ~/.local/bin/bat
    fi
fi

# Install eza (replacement for exa)
if ! command -v eza >/dev/null 2>&1; then
    echo "Installing eza..."
    sudo apt install -y eza 2>/dev/null || {
        # If eza is not available in repos, install via cargo
        if command -v cargo >/dev/null 2>&1; then
            cargo install eza
        else
            echo "Warning: eza could not be installed"
        fi
    }
fi

# Install ripgrep
if ! command -v rg >/dev/null 2>&1; then
    echo "Installing ripgrep..."
    sudo apt install -y ripgrep
fi

# Install fd
if ! command -v fd >/dev/null 2>&1; then
    echo "Installing fd..."
    sudo apt install -y fd-find
    # Create symlink
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        mkdir -p ~/.local/bin
        ln -s $(which fdfind) ~/.local/bin/fd
    fi
fi

# Install fzf
if ! command -v fzf >/dev/null 2>&1; then
    echo "Installing fzf..."
    sudo apt install -y fzf
fi

# Additional useful tools
additional_packages=(
    "htop"
    "ncdu"
    "tree"
    "jq"
    "httpie"
    "xclip"  # for clipboard support
    "inxi"   # system information
)

for package in "${additional_packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "Installing $package..."
        sudo apt install -y "$package" 2>/dev/null || echo "Warning: $package could not be installed"
    fi
done

# Install NVM for Node.js
if [[ ! -d "$HOME/.nvm" ]]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
fi

# WSL-specific setup
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo "Detected WSL environment, performing WSL-specific setup..."
    
    # Install wslu (WSL utilities)
    if ! command -v wslview >/dev/null 2>&1; then
        echo "Installing wslu..."
        sudo apt install -y wslu 2>/dev/null || {
            # Install from GitHub if not in repos
            wget -O - https://pkg.wslutiliti.es/public.key | sudo apt-key add -
            echo "deb https://pkg.wslutiliti.es/debian $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list
            sudo apt update
            sudo apt install -y wslu
        }
    fi
fi

# Make zsh the default shell if it isn't already
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# Development environment setup
if [[ -f "$DOTFILES_DIR/common/setup_dev_env.sh" ]]; then
    echo "💻 Running development environment setup..."
    chmod +x "$DOTFILES_DIR/common/setup_dev_env.sh"
    source "$DOTFILES_DIR/common/setup_dev_env.sh"
fi

echo "✅ Linux/WSL setup complete!"

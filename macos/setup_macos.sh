#!/bin/bash
# macOS-specific setup script

echo "🍎 Setting up macOS environment..."

# Install Homebrew if not already installed
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

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

# Load package lists and install packages
echo "📦 Installing packages..."
source "$DOTFILES_DIR/macos/packages.sh"

# Install packages based on user preference
echo "Choose installation option:"
echo "1) Essential only (CLI tools + essential apps)"
echo "2) Full development setup (includes dev tools)"
echo "3) Everything (includes communication apps)"
echo "4) Custom selection"

read -p "Enter choice (1-4) [default: 1]: " install_choice
install_choice=${install_choice:-1}

case $install_choice in
    1)
        install_cli_packages
        install_essential_apps
        install_fonts
        ;;
    2)
        install_cli_packages
        install_essential_apps
        install_dev_apps
        install_fonts
        ;;
    3)
        install_cli_packages
        install_essential_apps
        install_dev_apps
        install_comm_apps
        install_fonts
        ;;
    4)
        install_cli_packages
        install_essential_apps
        echo ""
        read -p "Install development applications? (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && install_dev_apps
        echo ""
        read -p "Install communication applications? (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && install_comm_apps
        echo ""
        read -p "Install optional applications? (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && install_optional_apps
        install_fonts
        ;;
    *)
        echo "Invalid choice, installing essentials only"
        install_cli_packages
        install_essential_apps
        install_fonts
        ;;
esac

# Make zsh the default shell if it isn't already
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Setting zsh as default shell..."
    chsh -s $(which zsh)
fi

# Create symlink for macOS .osx file
if [[ -f "$DOTFILES_DIR/macos/dotfiles/.osx" ]]; then
    ln -sf "$DOTFILES_DIR/macos/dotfiles/.osx" "$HOME/.osx"
fi

# Setup VS Code settings if VS Code is installed
if command -v code >/dev/null 2>&1 && [[ -f "$DOTFILES_DIR/vscode/settings.json" ]]; then
    echo "⚙️  Setting up VS Code configuration..."
    mkdir -p "$HOME/Library/Application Support/Code/User"
    ln -sf "$DOTFILES_DIR/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
fi

# Run additional setup scripts
echo "🔧 Running additional setup scripts..."

# Development environment setup
if [[ -f "$DOTFILES_DIR/common/setup_dev_env.sh" ]]; then
    echo "💻 Running development environment setup..."
    chmod +x "$DOTFILES_DIR/common/setup_dev_env.sh"
    source "$DOTFILES_DIR/common/setup_dev_env.sh"
fi

# Dotfiles setup (including .gitconfig generation)
if [[ -f "$DOTFILES_DIR/common/setup_dotfiles.sh" ]]; then
    echo "📝 Running dotfiles setup..."
    chmod +x "$DOTFILES_DIR/common/setup_dotfiles.sh"
    "$DOTFILES_DIR/common/setup_dotfiles.sh" install
fi

echo "✅ macOS setup complete!"
echo ""
echo "🔧 Additional tools available:"
echo "• System maintenance: ./common/system_maintenance.sh"
echo "• Package management: ./common/package_manager.sh"
echo "• Run 'validate.sh' to check your setup"

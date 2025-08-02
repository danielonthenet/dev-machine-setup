#!/bin/bash
# Development Environment Setup Script

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/detect_os.sh"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$HOME/.dotfiles-install.log"
}

log "💻 Setting up Development Environment..."

# Ruby - using rbenv
setup_ruby() {
    log "💎 Setting up Ruby with rbenv..."
    
    if [[ "$DOTFILES_OS" == "macos" ]]; then
        if ! command -v rbenv &> /dev/null; then
            brew install rbenv ruby-build
        fi
    else
        if ! command -v rbenv &> /dev/null; then
            # Install rbenv dependencies
            sudo apt update
            sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev \
                autoconf bison build-essential libyaml-dev libreadline-dev \
                libncurses5-dev libffi-dev libgdbm-dev
            
            # Install rbenv from GitHub
            git clone https://github.com/rbenv/rbenv.git ~/.rbenv
            git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
        fi
    fi
    
    # Initialize rbenv for current session
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    
    # Install latest stable Ruby
    local latest_ruby=$(rbenv install -l | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
    if [[ -n "$latest_ruby" && ! -d "$HOME/.rbenv/versions/$latest_ruby" ]]; then
        log "Installing Ruby $latest_ruby..."
        rbenv install "$latest_ruby"
        rbenv global "$latest_ruby"
        
        # Install bundler
        gem install bundler
        rbenv rehash
    fi
}

# Python - using pyenv
setup_python() {
    log "🐍 Setting up Python with pyenv..."
    
    if [[ "$DOTFILES_OS" == "macos" ]]; then
        if ! command -v pyenv &> /dev/null; then
            brew install pyenv
        fi
    else
        if ! command -v pyenv &> /dev/null; then
            # Install dependencies
            sudo apt update
            sudo apt install -y make build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                libffi-dev liblzma-dev
            
            # Install pyenv
            curl https://pyenv.run | bash
        fi
    fi
    
    # Initialize pyenv for current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    # Install latest stable Python
    local latest_python=$(pyenv install --list | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')
    if [[ -n "$latest_python" && ! -d "$PYENV_ROOT/versions/$latest_python" ]]; then
        log "Installing Python $latest_python..."
        pyenv install "$latest_python"
        pyenv global "$latest_python"
        
        # Install common Python tools
        pip install --upgrade pip
        pip install pipenv poetry black pylint flake8 mypy
    fi
}

# Go - using g (go version manager)
setup_go() {
    log "🐹 Setting up Go with g (go version manager)..."
    
    if ! command -v g &> /dev/null; then
        # Install g (go version manager)
        curl -sSL https://git.io/g-install | sh -s
    fi
    
    # Initialize Go environment
    export GOPATH="$HOME/go"
    export GOROOT="$HOME/.g/go"
    export PATH="$HOME/.g/bin:$PATH"
    export PATH="$GOPATH/bin:$PATH"
    
    # Install latest stable Go
    if command -v g &> /dev/null; then
        log "Installing latest Go..."
        g install latest
        g set latest
        
        # Create Go workspace
        mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg"
        
        # Install Go development tools
        go install golang.org/x/tools/gopls@latest
        go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
        go install github.com/air-verse/air@latest
    fi
}

# Terraform - using tfswitch
setup_terraform() {
    log "🏗️ Setting up Terraform with tfswitch..."
    
    if [[ "$DOTFILES_OS" == "macos" ]]; then
        if ! command -v tfswitch &> /dev/null; then
            brew install warrensbox/tap/tfswitch
        fi
    else
        if ! command -v tfswitch &> /dev/null; then
            # Install tfswitch
            curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
        fi
    fi
    
    # Install latest stable Terraform
    if command -v tfswitch &> /dev/null; then
        log "Installing latest stable Terraform..."
        tfswitch --latest-stable
        
        # Add terraform completion
        if command -v terraform &> /dev/null; then
            terraform -install-autocomplete 2>/dev/null || true
        fi
    fi
}

# Node.js - using nvm
setup_nodejs() {
    log "📦 Setting up Node.js with nvm..."
    
    if ! command -v nvm &> /dev/null; then
        log "Installing nvm..."
        if [[ "$DOTFILES_OS" == "macos" ]]; then
            # Install nvm via Homebrew or curl
            if command -v brew &> /dev/null; then
                brew install nvm
                # Create nvm directory
                mkdir -p ~/.nvm
            else
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
            fi
        else
            # Install nvm on Linux
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
        fi
        
        # Source nvm for current session
        export NVM_DIR="$HOME/.nvm"
        if [[ "$DOTFILES_OS" == "macos" && -d "/opt/homebrew/opt/nvm" ]]; then
            [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
        else
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        fi
    fi
    
    # Install latest LTS Node.js
    if command -v nvm &> /dev/null; then
        log "Installing latest LTS Node.js..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        
        # Install global packages
        npm install -g yarn pnpm
        npm install -g @angular/cli create-react-app vue-cli
        npm install -g typescript ts-node nodemon
        npm install -g eslint prettier
        npm install -g firebase-tools vercel
    fi
}

# Main setup function
setup_languages() {
    local languages=("$@")
    
    if [[ ${#languages[@]} -eq 0 ]]; then
        languages=("ruby" "python" "go" "terraform" "nodejs")
    fi
    
    for lang in "${languages[@]}"; do
        case "$lang" in
            ruby)
                setup_ruby
                ;;
            python)
                setup_python
                ;;
            go)
                setup_go
                ;;
            terraform)
                setup_terraform
                ;;
            nodejs)
                setup_nodejs
                ;;
            *)
                echo "⚠️  Unknown language: $lang"
                ;;
        esac
    done
}

# Interactive setup if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "🚀 Development Environment Setup"
    echo "Select languages to install:"
    echo "1) All (Ruby, Python, Go, Terraform, Node.js)"
    echo "2) Required only (Ruby, Python, Go, Terraform)"
    echo "3) Custom selection"
    echo "4) Exit"
    
    read -p "Choose an option [1-4]: " choice
    
    case $choice in
        1)
            setup_languages
            ;;
        2)
            setup_languages "ruby" "python" "go" "terraform"
            ;;
        3)
            selected_languages=()
            echo "Select languages (y/n):"
            
            read -p "Ruby? [y/N]: " ruby_choice
            [[ "$ruby_choice" =~ ^[Yy]$ ]] && selected_languages+=("ruby")
            
            read -p "Python? [y/N]: " python_choice
            [[ "$python_choice" =~ ^[Yy]$ ]] && selected_languages+=("python")
            
            read -p "Go? [y/N]: " go_choice
            [[ "$go_choice" =~ ^[Yy]$ ]] && selected_languages+=("go")
            
            read -p "Terraform? [y/N]: " terraform_choice
            [[ "$terraform_choice" =~ ^[Yy]$ ]] && selected_languages+=("terraform")
            
            read -p "Node.js? [y/N]: " nodejs_choice
            [[ "$nodejs_choice" =~ ^[Yy]$ ]] && selected_languages+=("nodejs")
            
            if [[ ${#selected_languages[@]} -gt 0 ]]; then
                setup_languages "${selected_languages[@]}"
            else
                echo "No languages selected."
            fi
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
    
    echo "✅ Development environment setup complete!"
    log "Please restart your shell or run: exec zsh"
else
    # When sourced, install required languages
    setup_languages "ruby" "python" "go" "terraform"
fi

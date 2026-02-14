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
    "gemini-cli"
    "watch"
)

# Development tools
DEV_PACKAGES=(
    "git-lfs"
    "gh"
    "node"
    "nvm"
    "goenv"
    "rbenv"
    "ruby-build"
    "python@3.12"
    "pyenv"
    "podman"
    "podman-compose"
    "slp/krunkit/krunkit"
    "kubernetes-cli"
    "helm"
    "kubectx"
    "kubeconform"
    "awscli"
    "azure-cli"
    "warrensbox/tap/tfswitch"
    "hashicorp/tap/terraform"
    "hashicorp/tap/consul"
    "hashicorp/tap/vault"
    "tflint"
    "checkov"
)

# NPM Global Packages
NPM_PACKAGES=(
    "@anthropic-ai/claude-code"
    "reveal-md"
)

# Python Packages (installed via pip)
PYTHON_PACKAGES=(
    "yamale"
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
    "raycast"
)

# Development GUI Applications
DEV_CASK_APPS=(
    "gcloud-cli"
    "postman"
    "dbeaver-community"
    "github"
    "wireshark"
    "git-credential-manager"
    "leapp"
    "openlens"
)

# Communication & Productivity Applications
COMM_CASK_APPS=(
    "slack"
    "keepassxc"
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

# Function to install NPM global packages
install_npm_packages() {
    echo "📦 Installing NPM global packages..."
    if command -v npm >/dev/null 2>&1; then
        for package in "${NPM_PACKAGES[@]}"; do
            if ! npm list -g "$package" >/dev/null 2>&1; then
                echo "Installing $package..."
                npm install -g "$package"
            else
                echo "✅ $package already installed"
            fi
        done
    else
        echo "⚠️  npm not found. Installing Node.js first..."
        brew install node
        install_npm_packages
    fi
}

# Function to install Python packages
install_python_packages() {
    echo "🐍 Installing Python packages..."
    
    # Check if pipx is available (recommended for CLI tools)
    if ! command -v pipx >/dev/null 2>&1; then
        echo "Installing pipx for Python CLI tools..."
        brew install pipx
        pipx ensurepath
    fi
    
    # Install packages using pipx (isolated environments, globally available)
    for package in "${PYTHON_PACKAGES[@]}"; do
        if ! command -v "$package" >/dev/null 2>&1; then
            echo "Installing $package..."
            pipx install "$package"
        else
            echo "✅ $package already installed"
        fi
    done
}

# Function to add required taps
add_required_taps() {
    echo "🍺 Adding required Homebrew taps..."

    # HashiCorp tap for Consul and Vault
    if ! brew tap | grep -q "hashicorp/tap"; then
        echo "Adding hashicorp/tap..."
        brew tap hashicorp/tap
    fi

    # Warren's tap for tfswitch
    if ! brew tap | grep -q "warrensbox/tap"; then
        echo "Adding warrensbox/tap..."
        brew tap warrensbox/tap
    fi

    # Noovolari tap for Leapp CLI
    if ! brew tap | grep -q "Noovolari/brew"; then
        echo "Adding Noovolari/brew..."
        brew tap Noovolari/brew
    fi

    # krunkit tap for Podman support
    if ! brew tap | grep -q "slp/krunkit"; then
        echo "Adding slp/krunkit..."
        brew tap slp/krunkit
    fi
}

# Function to install CLI packages
install_cli_packages() {
    echo "🔧 Installing CLI tools..."
    
    # Add required taps first
    add_required_taps
    
    for package in "${CLI_PACKAGES[@]}" "${DEV_PACKAGES[@]}"; do
        # Extract just the package name for checking if it's installed
        package_name=$(basename "$package")
        
        if ! brew list "$package_name" >/dev/null 2>&1; then
            echo "Installing $package..."
            brew install "$package"
        else
            echo "✅ $package_name already installed"
        fi
    done
    
    # Install architecture-specific Leapp CLI
    install_leapp_cli
    
    # Install AWS Session Manager Plugin
    install_aws_session_manager_plugin
}

# Function to install Leapp CLI (architecture-specific)
install_leapp_cli() {
    echo "🔐 Installing Leapp CLI..."
    
    # Detect architecture
    local arch=$(uname -m)
    local leapp_package=""
    
    if [[ "$arch" == "arm64" ]]; then
        leapp_package="Noovolari/brew/leapp-cli-darwin-arm64"
        echo "Detected Apple Silicon (ARM64) - installing ARM64 version"
    else
        leapp_package="Noovolari/brew/leapp-cli"
        echo "Detected Intel Mac - installing standard version"
    fi
    
    # Check if any Leapp CLI version is already installed
    if brew list | grep -q "leapp-cli"; then
        echo "✅ Leapp CLI already installed"
    else
        echo "Installing $leapp_package..."
        if brew install "$leapp_package"; then
            # Try to link if needed (common issue on some systems)
            brew link leapp-cli 2>/dev/null || echo "Note: Manual linking may be required"
            echo "✅ Leapp CLI installed successfully"
            echo "💡 Remember: Leapp CLI requires the desktop app to be running"
        else
            echo "⚠️  Failed to install Leapp CLI"
        fi
    fi
}

# Function to install AWS Session Manager Plugin
install_aws_session_manager_plugin() {
    echo "🔗 Installing AWS Session Manager Plugin..."
    
    # Check if already installed
    if command -v session-manager-plugin >/dev/null 2>&1; then
        echo "✅ AWS Session Manager Plugin already installed"
        return 0
    fi
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Determine architecture and download appropriate package
    local arch=$(uname -m)
    local download_url=""
    
    if [[ "$arch" == "arm64" ]]; then
        download_url="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip"
        echo "Detected Apple Silicon (ARM64) - downloading ARM64 version"
    else
        download_url="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip"
        echo "Detected Intel Mac - downloading Intel version"
    fi
    
    # Download and install
    echo "Downloading AWS Session Manager Plugin..."
    if curl -o "sessionmanager-bundle.zip" "$download_url"; then
        echo "Extracting and installing..."
        unzip sessionmanager-bundle.zip
        sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
        
        if command -v session-manager-plugin >/dev/null 2>&1; then
            echo "✅ AWS Session Manager Plugin installed successfully"
            echo "Plugin version: $(session-manager-plugin --version)"
        else
            echo "⚠️  Installation may have failed - plugin not found in PATH"
        fi
    else
        echo "⚠️  Failed to download AWS Session Manager Plugin"
    fi
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$temp_dir"
}

# Function to install Cloud SQL Proxy
install_cloud_sql_proxy() {
    echo "☁️  Installing Cloud SQL Proxy..."
    
    # Check if already installed
    if command -v cloud-sql-proxy >/dev/null 2>&1; then
        echo "✅ Cloud SQL Proxy already installed"
        local current_version=$(cloud-sql-proxy --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo "Current version: $current_version"
        return 0
    fi
    
    # Set version and download URL
    local VERSION="v2.19.0"
    local URL="https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/$VERSION"
    local ARCH="darwin.arm64"
    
    # Detect architecture (Intel vs Apple Silicon)
    if [[ $(uname -m) == "x86_64" ]]; then
        ARCH="darwin.amd64"
    fi
    
    echo "Downloading Cloud SQL Proxy $VERSION for $ARCH..."
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download the binary
    if curl -fsSL "$URL/cloud-sql-proxy.$ARCH" -o cloud-sql-proxy; then
        echo "Download successful"
        
        # Make it executable
        chmod +x cloud-sql-proxy
        
        # Move to /usr/local/bin
        sudo mv cloud-sql-proxy /usr/local/bin/
        
        # Verify installation
        if command -v cloud-sql-proxy >/dev/null 2>&1; then
            echo "✅ Cloud SQL Proxy installed successfully"
            cloud-sql-proxy --version
        else
            echo "⚠️  Installation may have failed - cloud-sql-proxy not found in PATH"
            return 1
        fi
    else
        echo "❌ Failed to download Cloud SQL Proxy"
        cd - >/dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$temp_dir"
    
    echo ""
    echo "📖 Usage: cloud-sql-proxy <INSTANCE_CONNECTION_NAME>"
    echo "Example: cloud-sql-proxy project:region:instance"
    echo "For more info: cloud-sql-proxy --help"
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

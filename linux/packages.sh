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
    "procps"
)

# Additional CLI tools (installed via other methods)
ADVANCED_CLI_TOOLS=(
    "yq"
    "eza"
    "dust"
    "duf"
)

# Development tools
DEV_PACKAGES=(
    "nodejs"
    "npm"
    "podman"
    "podman-compose"
    "git-lfs"
)

# Kubernetes tools (installed separately via specific repos)
K8S_TOOLS=(
    "kubectl"
    "helm"
)

# GUI applications (for desktop Linux, not WSL)
GUI_PACKAGES=(
    "keepassxc"
)

# NPM Global Packages
NPM_PACKAGES=(
    "@anthropic-ai/claude-code"
    "@google/gemini-cli"
    "reveal-md"
)

# Python Packages (installed via pip)
PYTHON_PACKAGES=(
    "yamale"
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
    
    # Install Leapp CLI via Homebrew/Linuxbrew (works in WSL)
    install_leapp_cli
}

# Function to install Leapp CLI for Linux/WSL
install_leapp_cli() {
    echo "🔐 Installing Leapp CLI..."
    
    # Check if brew is available (Linuxbrew)
    if command -v brew >/dev/null 2>&1; then
        if ! brew list | grep -q "leapp-cli"; then
            echo "Installing Leapp CLI via Homebrew..."
            if brew install Noovolari/brew/leapp-cli; then
                # Try to link if needed
                brew link leapp-cli 2>/dev/null || echo "Note: Manual linking may be required"
                echo "✅ Leapp CLI installed successfully"
                echo "💡 Note: For WSL, ensure the Leapp desktop app is running on Windows"
            else
                echo "⚠️  Failed to install Leapp CLI via Homebrew"
            fi
        else
            echo "✅ Leapp CLI already installed"
        fi
    else
        echo "⚠️  Homebrew/Linuxbrew not found. Please install Homebrew first or install Leapp CLI manually"
        echo "💡 Installation guide: https://docs.leapp.cloud/latest/installation/install-leapp/"
    fi
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

# Function to install GUI packages (desktop Linux only)
install_gui_packages() {
    echo "🖥️  Installing GUI applications..."
    # Check if we're in a desktop environment (not WSL)
    if [[ -z "$WSL_DISTRO_NAME" ]] && [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
        for package in "${GUI_PACKAGES[@]}"; do
            if ! dpkg -l | grep -q "^ii  $package "; then
                echo "Installing $package..."
                sudo apt install -y "$package"
            fi
        done
    else
        echo "Skipping GUI packages (not in desktop environment or running in WSL)"
    fi
}

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
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y nodejs npm
        else
            echo "Please install Node.js and npm manually"
            return 1
        fi
        install_npm_packages
    fi
}

# Function to install Git Credential Manager
install_git_credential_manager() {
    echo "🔐 Installing Git Credential Manager..."
    
    # Check if already installed
    if command -v git-credential-manager >/dev/null 2>&1; then
        echo "✅ Git Credential Manager already installed"
        return 0
    fi
    
    # Check if .NET 8.0 SDK is available
    if ! command -v dotnet >/dev/null 2>&1; then
        echo "Installing .NET 8.0 SDK..."
        if command -v apt >/dev/null 2>&1; then
            # Add Microsoft package repository
            wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            sudo dpkg -i packages-microsoft-prod.deb
            rm packages-microsoft-prod.deb
            
            # Install .NET SDK
            sudo apt update
            sudo apt install -y dotnet-sdk-8.0
        else
            echo "Please install .NET 8.0 SDK manually from https://learn.microsoft.com/en-us/dotnet/core/install/linux"
            return 1
        fi
    fi
    
    # Install git-credential-manager via .NET tool
    echo "Installing Git Credential Manager via .NET tool..."
    dotnet tool install -g git-credential-manager
    
    # Configure git-credential-manager
    if command -v git-credential-manager >/dev/null 2>&1; then
        echo "Configuring Git Credential Manager..."
        git-credential-manager configure
        echo "✅ Git Credential Manager installed and configured"
    else
        echo "⚠️  Installation may have succeeded but git-credential-manager not in PATH"
        echo "You may need to add ~/.dotnet/tools to your PATH"
        echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.bashrc
        echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.zshrc 2>/dev/null || true
    fi
}

# Function to install Kubernetes tools (kubectl, helm)
install_k8s_tools() {
    echo "☸️  Installing Kubernetes tools..."

    # Install kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        echo "Installing kubectl..."

        # Download the latest kubectl
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

        # Install kubectl
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl

        echo "✅ kubectl installed successfully"
    else
        echo "✅ kubectl already installed"
    fi

    # Install Helm 3
    if ! command -v helm >/dev/null 2>&1; then
        echo "Installing Helm 3..."

        # Use official Helm installation script
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
        chmod 700 get_helm.sh
        ./get_helm.sh
        rm get_helm.sh

        echo "✅ Helm 3 installed successfully"
    else
        echo "✅ Helm already installed"
    fi

    # Verify installations
    if command -v kubectl >/dev/null 2>&1; then
        echo "kubectl version: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    fi

    if command -v helm >/dev/null 2>&1; then
        echo "Helm version: $(helm version --short)"
    fi
}

# Function to install HashiCorp tools (Terraform, Consul, and Vault)
install_hashicorp_tools() {
    echo "🔐 Installing HashiCorp tools (Terraform, Consul, and Vault)..."

    # Add HashiCorp GPG key and repository
    if ! command -v terraform >/dev/null 2>&1 || ! command -v consul >/dev/null 2>&1 || ! command -v vault >/dev/null 2>&1; then
        echo "Adding HashiCorp repository..."
        # Download and install the HashiCorp GPG key (modern method)
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        # Add the HashiCorp repository with signed-by option
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update
    fi

    # Install Terraform
    if ! command -v terraform >/dev/null 2>&1; then
        echo "Installing Terraform..."
        sudo apt-get install -y terraform
        echo "✅ Terraform installed successfully"
    else
        echo "✅ Terraform already installed"
    fi

    # Install Consul
    if ! command -v consul >/dev/null 2>&1; then
        echo "Installing Consul..."
        sudo apt-get install -y consul
        echo "✅ Consul installed successfully"
    else
        echo "✅ Consul already installed"
    fi

    # Install Vault
    if ! command -v vault >/dev/null 2>&1; then
        echo "Installing Vault..."
        sudo apt-get install -y vault
        echo "✅ Vault installed successfully"
    else
        echo "✅ Vault already installed"
    fi

    # Verify installations
    if command -v terraform >/dev/null 2>&1; then
        echo "Terraform version: $(terraform version | head -n1)"
    fi

    if command -v consul >/dev/null 2>&1; then
        echo "Consul version: $(consul version | head -n1)"
    fi

    if command -v vault >/dev/null 2>&1; then
        echo "Vault version: $(vault version | head -n1)"
    fi
}

# Function to install Terraform validation tools (tflint and checkov)
install_terraform_validation_tools() {
    echo "🔍 Installing Terraform validation tools..."
    
    # Install tflint
    if ! command -v tflint >/dev/null 2>&1; then
        echo "Installing tflint..."
        
        # Get the latest version of tflint
        TFLINT_VERSION=$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        
        if [[ -z "$TFLINT_VERSION" ]]; then
            echo "⚠️  Could not determine latest tflint version, using fallback"
            TFLINT_VERSION="v0.50.3"
        fi
        
        # Download and install tflint
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
        
        # Verify installation
        if command -v tflint >/dev/null 2>&1; then
            echo "✅ tflint installed successfully"
        else
            echo "⚠️  tflint installation may have failed"
        fi
    else
        echo "✅ tflint already installed"
    fi
    
    # Install checkov via pip3
    if ! command -v checkov >/dev/null 2>&1; then
        echo "Installing checkov..."
        
        # Ensure pip3 is available
        if ! command -v pip3 >/dev/null 2>&1; then
            echo "Installing python3-pip..."
            sudo apt update && sudo apt install -y python3-pip
        fi
        
        # Install checkov
        pip3 install --user checkov
        
        # Add ~/.local/bin to PATH if not already there (where pip3 --user installs)
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
            export PATH="$HOME/.local/bin:$PATH"
        fi
        
        # Verify installation
        if command -v checkov >/dev/null 2>&1; then
            echo "✅ checkov installed successfully"
        else
            echo "⚠️  checkov installation may have failed or PATH needs to be refreshed"
            echo "Try running: source ~/.bashrc or source ~/.zshrc"
        fi
    else
        echo "✅ checkov already installed"
    fi
    
    # Display versions
    if command -v tflint >/dev/null 2>&1; then
        echo "tflint version: $(tflint --version)"
    fi
    
    if command -v checkov >/dev/null 2>&1; then
        echo "checkov version: $(checkov --version | head -n1)"
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
    
    # Determine architecture
    local arch=$(uname -m)
    local download_url=""
    local package_name=""
    
    if [[ "$arch" == "x86_64" ]]; then
        download_url="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb"
        package_name="session-manager-plugin.deb"
        echo "Detected x86_64 architecture"
    elif [[ "$arch" == "aarch64" ]]; then
        download_url="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb"
        package_name="session-manager-plugin.deb"
        echo "Detected ARM64 architecture"
    else
        echo "⚠️  Unsupported architecture: $arch"
        cd - >/dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Download and install
    echo "Downloading AWS Session Manager Plugin..."
    if curl -o "$package_name" "$download_url"; then
        echo "Installing via dpkg..."
        sudo dpkg -i "$package_name"
        
        # Fix any dependency issues
        sudo apt-get install -f -y
        
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

# Function to install advanced CLI tools (yq, eza, etc.)
install_advanced_cli_tools() {
    echo "🚀 Installing advanced CLI tools..."
    
    # Install yq
    if ! command -v yq >/dev/null 2>&1; then
        echo "Installing yq..."
        
        # Determine architecture
        local arch=$(uname -m)
        local yq_binary=""
        
        if [[ "$arch" == "x86_64" ]]; then
            yq_binary="yq_linux_amd64"
        elif [[ "$arch" == "aarch64" ]]; then
            yq_binary="yq_linux_arm64"
        else
            echo "⚠️  Unsupported architecture for yq: $arch"
            return 1
        fi
        
        # Download and install yq
        sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/${yq_binary}"
        sudo chmod +x /usr/local/bin/yq
        
        if command -v yq >/dev/null 2>&1; then
            echo "✅ yq installed successfully ($(yq --version))"
        else
            echo "⚠️  yq installation may have failed"
        fi
    else
        echo "✅ yq already installed"
    fi
    
    # Install eza (modern replacement for ls)
    if ! command -v eza >/dev/null 2>&1; then
        echo "Installing eza..."
        
        # Try to install from package manager first
        if sudo apt install -y eza 2>/dev/null; then
            echo "✅ eza installed from apt"
        elif command -v cargo >/dev/null 2>&1; then
            echo "Installing eza via cargo..."
            cargo install eza
            echo "✅ eza installed via cargo"
        else
            echo "⚠️  Could not install eza (cargo not available)"
        fi
    else
        echo "✅ eza already installed"
    fi
}

# Function to install Kubernetes validation tools (kubeconform)
install_k8s_validation_tools() {
    echo "☸️  Installing Kubernetes validation tools..."
    
    # Install kubeconform
    if ! command -v kubeconform >/dev/null 2>&1; then
        echo "Installing kubeconform..."
        
        # Get the latest version
        KUBECONFORM_VERSION=$(curl -s https://api.github.com/repos/yannh/kubeconform/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        
        if [[ -z "$KUBECONFORM_VERSION" ]]; then
            echo "⚠️  Could not determine latest kubeconform version, using fallback"
            KUBECONFORM_VERSION="0.6.4"
        fi
        
        # Determine architecture
        local arch=$(uname -m)
        local kubeconform_binary=""
        
        if [[ "$arch" == "x86_64" ]]; then
            kubeconform_binary="kubeconform-linux-amd64.tar.gz"
        elif [[ "$arch" == "aarch64" ]]; then
            kubeconform_binary="kubeconform-linux-arm64.tar.gz"
        else
            echo "⚠️  Unsupported architecture for kubeconform: $arch"
            return 1
        fi
        
        # Create temp directory
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        # Download and install
        echo "Downloading kubeconform v${KUBECONFORM_VERSION}..."
        if curl -sL "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/${kubeconform_binary}" | tar xz; then
            sudo mv kubeconform /usr/local/bin/
            sudo chmod +x /usr/local/bin/kubeconform
            
            if command -v kubeconform >/dev/null 2>&1; then
                echo "✅ kubeconform installed successfully ($(kubeconform -v))"
            else
                echo "⚠️  kubeconform installation may have failed"
            fi
        else
            echo "⚠️  Failed to download kubeconform"
        fi
        
        # Cleanup
        cd - >/dev/null
        rm -rf "$temp_dir"
    else
        echo "✅ kubeconform already installed"
    fi
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
    local ARCH="linux.amd64"
    
    # Detect architecture
    local arch=$(uname -m)
    if [[ "$arch" == "aarch64" ]] || [[ "$arch" == "arm64" ]]; then
        ARCH="linux.arm64"
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
            cd - >/dev/null
            rm -rf "$temp_dir"
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

# Function to install Python packages
install_python_packages() {
    echo "🐍 Installing Python packages..."
    
    # Check if pipx is available (recommended for CLI tools)
    if ! command -v pipx >/dev/null 2>&1; then
        echo "Installing pipx for Python CLI tools..."
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y pipx
            pipx ensurepath
        elif command -v brew >/dev/null 2>&1; then
            brew install pipx
            pipx ensurepath
        else
            # Fallback to pip install
            if ! command -v pip3 >/dev/null 2>&1; then
                echo "Installing python3-pip..."
                sudo apt update && sudo apt install -y python3-pip
            fi
            pip3 install --user pipx
            python3 -m pipx ensurepath
        fi
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
    
    echo "✅ Python packages installation complete"
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
            install_advanced_cli_tools
            install_npm_packages
            install_python_packages
            install_git_credential_manager
            ;;
        2)
            install_essential_packages
            install_cli_packages
            install_advanced_cli_tools
            install_dev_packages
            install_npm_packages
            install_python_packages
            install_git_credential_manager
            install_k8s_tools
            install_k8s_validation_tools
            install_hashicorp_tools
            install_terraform_validation_tools
            install_aws_session_manager_plugin
            ;;
        3)
            install_essential_packages
            install_cli_packages
            install_advanced_cli_tools
            install_dev_packages
            install_gui_packages
            install_npm_packages
            install_python_packages
            install_git_credential_manager
            install_k8s_tools
            install_k8s_validation_tools
            install_hashicorp_tools
            install_terraform_validation_tools
            install_aws_session_manager_plugin
            install_snap_packages
            ;;
        4)
            echo "Custom installation options:"
            read -p "Install essential packages? (y/n): " install_essential
            read -p "Install CLI tools? (y/n): " install_cli
            read -p "Install advanced CLI tools (yq, eza)? (y/n): " install_advanced_cli
            read -p "Install development tools? (y/n): " install_dev
            read -p "Install GUI applications? (y/n): " install_gui
            read -p "Install npm packages? (y/n): " install_npm
            read -p "Install Python packages (yamale)? (y/n): " install_python
            read -p "Install Git Credential Manager? (y/n): " install_gcm
            read -p "Install Kubernetes tools (kubectl/helm)? (y/n): " install_k8s
            read -p "Install Kubernetes validation tools (kubeconform)? (y/n): " install_k8s_validation
            read -p "Install HashiCorp tools (Consul/Vault)? (y/n): " install_hashicorp
            read -p "Install Terraform validation tools (tflint/checkov)? (y/n): " install_tf_validation
            read -p "Install AWS Session Manager Plugin? (y/n): " install_session_manager
            read -p "Install Cloud SQL Proxy? (y/n): " install_cloudsql
            read -p "Install snap packages? (y/n): " install_snap

            [[ $install_essential == "y" ]] && install_essential_packages
            [[ $install_cli == "y" ]] && install_cli_packages
            [[ $install_advanced_cli == "y" ]] && install_advanced_cli_tools
            [[ $install_dev == "y" ]] && install_dev_packages
            [[ $install_gui == "y" ]] && install_gui_packages
            [[ $install_npm == "y" ]] && install_npm_packages
            [[ $install_python == "y" ]] && install_python_packages
            [[ $install_gcm == "y" ]] && install_git_credential_manager
            [[ $install_k8s == "y" ]] && install_k8s_tools
            [[ $install_k8s_validation == "y" ]] && install_k8s_validation_tools
            [[ $install_hashicorp == "y" ]] && install_hashicorp_tools
            [[ $install_tf_validation == "y" ]] && install_terraform_validation_tools
            [[ $install_session_manager == "y" ]] && install_aws_session_manager_plugin
            [[ $install_cloudsql == "y" ]] && install_cloud_sql_proxy
            [[ $install_snap == "y" ]] && install_snap_packages
            ;;
        *)
            echo "Invalid choice. Installing essential packages only."
            install_essential_packages
            install_cli_packages
            install_npm_packages
            install_git_credential_manager
            ;;
    esac
}

# Run interactive install if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    interactive_install
fi

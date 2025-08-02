#!/bin/bash

# Detect operating system and set environment variables
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        export DOTFILES_OS="macos"
        export DOTFILES_PLATFORM="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]] && [[ -n "$WSL_DISTRO_NAME" ]]; then
        export DOTFILES_OS="linux"
        export DOTFILES_PLATFORM="wsl"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        export DOTFILES_OS="linux"
        export DOTFILES_PLATFORM="linux"
    else
        export DOTFILES_OS="unknown"
        export DOTFILES_PLATFORM="unknown"
    fi
}

# Load platform-specific configuration
load_platform_config() {
    # Use the DOTFILES_DIR set by the caller (e.g., .zshrc)
    local dotfiles_dir="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
    local os_dir="$dotfiles_dir/$DOTFILES_OS"
    local common_dir="$dotfiles_dir/common"
    
    # Export paths for use in other scripts
    export DOTFILES_DIR="$dotfiles_dir"
    export DOTFILES_OS_DIR="$os_dir"
    export DOTFILES_COMMON_DIR="$common_dir"
}

# Initialize detection
detect_os
load_platform_config

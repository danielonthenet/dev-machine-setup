#!/bin/bash
# Shared environment variables for all platforms

# Prevent duplicate PATH entries
remove_from_path() {
    export PATH=$(echo -n "$PATH" | awk -v RS=: -v ORS=: '!a[$1]++' | sed 's/:$//')
}

# Clean PATH before adding new entries
remove_from_path

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Version Manager Exports
export PYENV_ROOT="$HOME/.pyenv"
export GOENV_ROOT="$HOME/.goenv"
export GOPATH="$HOME/go"
export NVM_DIR="$HOME/.nvm"

# Development
export PYTHONDONTWRITEBYTECODE=1
export PIP_REQUIRE_VIRTUALENV=true
export KUBE_EDITOR="${EDITOR:-vim}"

# Security
export GPG_TTY=$(tty)

# Common PATH additions
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"

# Version Manager PATH additions
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$GOENV_ROOT/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"

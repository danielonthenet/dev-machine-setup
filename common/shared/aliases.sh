#!/bin/bash
# Shared aliases for all platforms

# Podman aliases
alias dps='podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='podman images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'
alias dclean='podman system prune -af'

# Docker compatibility aliases
alias docker='podman'
alias docker-compose='podman-compose'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'

# Common utilities
alias week='date +%V'
alias myip="curl -s https://api.ipify.org && echo"
alias reload="exec $SHELL -l"

# Configuration editing
alias zshconfig='$EDITOR ~/.zshrc'
alias vimconfig='$EDITOR ~/.vimrc'

# Modern tool replacements (if available)
command -v bat >/dev/null 2>&1 && alias cat='bat --style=numbers,changes,header'
command -v eza >/dev/null 2>&1 && alias ls='eza --icons' && alias ll='eza -la --git --header --icons'
command -v rg >/dev/null 2>&1 && alias grep='rg'

# Terraform
alias tf='terraform'

# System maintenance
alias maintenance='./common/system_maintenance.sh'
alias syshealth='./common/system_maintenance.sh health'
alias sysclean='./common/system_maintenance.sh clean'
alias sysupdate='./common/system_maintenance.sh update'

# Package management
alias pkgmgr='./common/package_manager.sh'
alias packages='./macos/packages.sh'
alias brewlist='brew list --formula && echo "=== CASKS ===" && brew list --cask'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Enhanced ls with fallback
if command -v eza >/dev/null 2>&1; then
    alias ll='eza -la --git --header --icons'
    alias la='eza -la --git --header --icons'
    alias lt='eza --tree --level=2'
else
    alias ll='ls -la'
    alias la='ls -la'
fi

# Quick edits
alias hosts='sudo $EDITOR /etc/hosts'
alias profile='$EDITOR ~/.zshrc'

# Process management
alias pgrep='pgrep -f'

# History
alias h='history'
alias hgrep='history | grep'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Version Manager Aliases
alias rb='rbenv'
alias rbv='rbenv versions'
alias rbi='rbenv install'
alias rbg='rbenv global'
alias rbl='rbenv local'

alias py='pyenv'
alias pyv='pyenv versions'
alias pyi='pyenv install'
alias pyg='pyenv global'
alias pyl='pyenv local'

alias gv='g list'
alias gi='g install'
alias gset='g set'

alias nv='nvm list'
alias ni='nvm install'
alias nu='nvm use'
alias nvm-default='nvm alias default'

alias tfs='tfswitch'
alias tfv='terraform version'

# Quick version checks
alias versions='echo "Ruby: $(ruby -v 2>/dev/null || echo "not installed")"; echo "Python: $(python --version 2>/dev/null || echo "not installed")"; echo "Go: $(go version 2>/dev/null || echo "not installed")"; echo "Node.js: $(node --version 2>/dev/null || echo "not installed")"; echo "Terraform: $(terraform version 2>/dev/null || echo "not installed")"'

# Version manager validation
alias validate-versions='./common/validate_version_managers.sh'
alias check-versions='show-versions'

# Dotfiles management
alias dotfiles-update='cd $DOTFILES_DIR && git pull && ./common/setup_dotfiles.sh install'
alias dotfiles-backup='cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)'
alias dotfiles-status='cd $DOTFILES_DIR && git status'

# Performance and validation
alias zsh-startup='zsh-profile'
alias dotfiles-check='dotfiles-quick-check'

# Quick edit configs
alias edit-dotfiles='$EDITOR $DOTFILES_DIR'
alias edit-zsh='$EDITOR ~/.zshrc'

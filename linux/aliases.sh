#!/bin/bash
# Linux/WSL-specific aliases

# GNU ls with colors
colorflag="--color"
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

alias l="ls -lF ${colorflag}"
alias la="ls -laF ${colorflag}"
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"
alias ls="command ls ${colorflag}"

# Linux package management
alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias install='sudo apt install'
alias search='apt search'
alias remove='sudo apt remove'
alias purge='sudo apt purge'

# System information
alias sysinfo='inxi -Fxz'
alias diskusage='df -h'
alias meminfo='free -h'
alias cpuinfo='lscpu'

# Network utilities
alias localip="hostname -I | awk '{print \$1}'"
alias ips="ip addr show | grep -o 'inet6\? \([0-9]\+\.\)\{3\}[0-9]\+' | awk '{print \$2}'"
alias ports='ss -tulanp'
alias listening='ss -tuln'
alias netstat='ss'

# Process management
alias pgrep='pgrep -l'
alias pkill='pkill'
alias topcpu='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head'
alias topmem='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'

# WSL-specific aliases
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    alias open='explorer.exe'
    alias start='cmd.exe /c start'
    alias explorer='explorer.exe'
    alias notepad='notepad.exe'
    alias powershell='powershell.exe'
    alias cmd='cmd.exe'
    alias windows='/mnt/c'
    alias desktop='/mnt/c/Users/$USER/Desktop'
    alias downloads='/mnt/c/Users/$USER/Downloads'
    alias documents='/mnt/c/Users/$USER/Documents'
    
    # WSL utilities
    alias wsl-restart='wsl.exe --shutdown'
    alias wsl-update='wsl.exe --update'
    alias winget='winget.exe'
fi

# Clipboard (depending on what's available)
if command -v xclip >/dev/null 2>&1; then
    alias c="tr -d '\n' | xclip -selection clipboard"
elif command -v xsel >/dev/null 2>&1; then
    alias c="tr -d '\n' | xsel --clipboard --input"
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    alias c="tr -d '\n' | clip.exe"
fi

# Service management
alias services='systemctl list-units --type=service'
alias start-service='sudo systemctl start'
alias stop-service='sudo systemctl stop'
alias restart-service='sudo systemctl restart'
alias enable-service='sudo systemctl enable'
alias disable-service='sudo systemctl disable'
alias status-service='systemctl status'

# Archive utilities
alias extract='atool -x'
alias compress='atool -a'

# File permissions
alias chmodx='chmod +x'
alias chown-me='sudo chown $USER:$USER'

# Git (additional Linux-specific)
alias gitlog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Modern tools (if installed)
command -v htop >/dev/null 2>&1 && alias top='htop'
command -v ncdu >/dev/null 2>&1 && alias du='ncdu'
command -v prettyping >/dev/null 2>&1 && alias ping='prettyping --nolegend'
command -v eza >/dev/null 2>&1 && alias ls='eza --icons' && alias ll='eza -la --git --header --icons' && alias tree='eza --tree --icons'

#!/bin/bash
# macOS-specific aliases

# Detect GNU or BSD ls
if ls --color > /dev/null 2>&1; then
    colorflag="--color"
else
    colorflag="-G"
fi

alias l="ls -lF ${colorflag}"
alias la="ls -laF ${colorflag}"
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"
alias ls="command ls ${colorflag}"

# Set LS_COLORS for macOS
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

# macOS-specific system commands
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup'
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Empty the Trash
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Network
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Clipboard
alias c="tr -d '\n' | pbcopy"

# Recursively delete .DS_Store files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Merge PDF files
alias mergepdf='/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py'

# Spotlight
alias spotoff="sudo mdutil -a -i off"
alias spoton="sudo mdutil -a -i on"

# PlistBuddy alias
alias plistbuddy="/usr/libexec/PlistBuddy"

# Ring terminal bell
alias badge="tput bel"

# Intuitive map function
alias map="xargs -n1"

# Kill Chrome tabs
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Lock screen
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Network tools
alias ipcalculator='whatmask'

# Git log with nice formatting  
alias gitlog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Modern tools
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons'
    alias ll='eza -la --git --header --icons'
    alias tree='eza --tree --icons'
fi

# Pretty tools
alias ping='prettyping --nolegend'

# Homebrew management
alias brewup='brew update && brew upgrade && brew cleanup'

# Development shortcuts
alias ports='lsof -i -P -n | grep LISTEN'
alias serve='python3 -m http.server 8000'
alias jsonpp='python3 -m json.tool'
alias urlencode='python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))"'

# File operations
alias cpwd='pwd | pbcopy'
alias finder='open -a Finder'
alias preview='open -a Preview'
alias edit='code'

# System information
alias cpu='top -l 1 | grep "CPU usage"'
alias mem='vm_stat'
alias disk='df -h'
alias battery='pmset -g batt'

# Network utilities
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias wifi='networksetup -getairportnetwork en0'
alias wifipass='security find-generic-password -ga "$(networksetup -getairportnetwork en0 | cut -d" " -f4)" -w'

# Process management
alias psg='ps aux | grep'
alias killport='function _killport(){ lsof -ti:$1 | xargs kill -9; }; _killport'

# Podman shortcuts
alias dex='podman exec -it'
alias dlog='podman logs -f'
alias drun='podman run --rm -it'
alias dvol='podman volume ls'
alias dnet='podman network ls'

# Docker compatibility aliases
alias docker='podman'
alias docker-compose='podman-compose'

# Kubernetes shortcuts  
alias kns='kubectl config set-context --current --namespace'
alias kgns='kubectl get namespaces'
alias kdesc='kubectl describe'
alias klog='kubectl logs -f'
alias kexec='kubectl exec -it'
alias kport='kubectl port-forward'

# macOS specific utilities
alias darkmode='osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to not dark mode"'
alias screensaver='open -a ScreenSaverEngine'
alias sleep='pmset sleepnow'
alias restart='sudo shutdown -r now'
alias shutdown='sudo shutdown -h now'

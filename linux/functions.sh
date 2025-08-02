#!/bin/bash
# Linux/WSL-specific functions

# Base64 decode (Linux uses -d)
base64-decode() {
    echo -n "$@" | base64 -d;
}

# WSL-specific: Open Windows Explorer at current location
explorer() {
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        if [[ $# -eq 0 ]]; then
            explorer.exe .
        else
            explorer.exe "$@"
        fi
    else
        echo "This function is only available in WSL"
    fi
}

# WSL-specific: Open file with default Windows application
start() {
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        cmd.exe /c start "$@"
    else
        xdg-open "$@"
    fi
}

# Create a .tar.gz archive
targz() {
    local tmpFile="${@%/}.tar";
    tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;
    gzip -v "${tmpFile}" || return 1;
    echo "${tmpFile}.gz created successfully.";
}

# WSL IP address for Windows host
wsl-ip() {
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        ip route show | grep -i default | awk '{ print $3}'
    else
        echo "This function is only available in WSL"
    fi
}

# Convert Windows path to WSL path
winpath() {
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        echo "$1" | sed 's|\\|/|g' | sed 's|C:|/mnt/c|g' | sed 's|D:|/mnt/d|g'
    else
        echo "This function is only available in WSL"
    fi
}

# Convert WSL path to Windows path
wslpath() {
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
        wslpath -w "$1"
    else
        echo "This function is only available in WSL"
    fi
}

# Get system information
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Distribution: $(lsb_release -d | cut -f2)"
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    echo "=== Memory Usage ==="
    free -h
    echo ""
    echo "=== Disk Usage ==="
    df -h /
    echo ""
    echo "=== Network Interfaces ==="
    ip -4 addr show | grep -E '(eth|wlan|enp|wlp)' | grep inet
}

# Extract any archive
extract() {
    if [ -f "$1" ] ; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Make a directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find files by name
ff() {
    find . -type f -iname "*$1*"
}

# Find directories by name
fd() {
    find . -type d -iname "*$1*"
}

# Get the size of a directory
dirsize() {
    du -sh "${1:-.}"
}

# Show PATH in a readable format
path() {
    echo $PATH | tr ':' '\n'
}

# Quick server for current directory
serve() {
    local port="${1:-8000}"
    echo "Serving at http://localhost:$port/"
    python3 -m http.server "$port"
}

# Process tree
pstree() {
    ps -eo pid,ppid,user,command --forest
}

# Kill process by name
killprocess() {
    if [ $# -eq 0 ]; then
        echo "Usage: killprocess <process_name>"
        return 1
    fi
    
    local pids=$(pgrep -f "$1")
    if [ -z "$pids" ]; then
        echo "No processes found matching '$1'"
        return 1
    fi
    
    echo "Found processes:"
    ps -p $pids -o pid,command
    echo ""
    read -p "Kill these processes? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill $pids
        echo "Processes killed"
    else
        echo "Cancelled"
    fi
}

#!/bin/bash
# macOS-specific functions

# Base64 decode (macOS uses -D)
base64-decode() {
    echo -n "$@" | base64 -D;
}

# Change working directory to the top-most Finder window location
cdf() { # short for `cdfinder`
    cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
targz() {
    local tmpFile="${@%/}.tar";
    tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

    size=$(
        stat -f"%z" "${tmpFile}" 2> /dev/null; # macOS `stat`
    );

    local cmd="";
    if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
        cmd="zopfli";
    else
        if hash pigz 2> /dev/null; then
            cmd="pigz";
        else
            cmd="gzip";
        fi;
    fi;

    echo "Compressing .tar using \`${cmd}\`…";
    "${cmd}" -v "${tmpFile}" || return 1;
    [ -f "${tmpFile}" ] && rm "${tmpFile}";
    echo "${tmpFile}.gz created successfully.";
}

# Start a PHP server from a directory, optionally specifying the port
phpserver() {
    local port="${1:-4000}";
    local ip=$(ipconfig getifaddr en1);
    sleep 1 && open "http://${ip}:${port}/" &
    php -S "${ip}:${port}";
}

# Syntax-highlight JSON strings or files
json() {
    if [ -t 0 ]; then # argument
        python -mjson.tool <<< "$*" | pygmentize -l javascript;
    else # pipe
        python -mjson.tool | pygmentize -l javascript;
    fi;
}

# Run `dig` and display the most useful info
digga() {
    dig +nocmd "$1" any +multiline +noall +answer;
}

# Show all the names (CNs and SANs) listed in the SSL certificate for a given domain
getcertnames() {
    if [ -z "${1}" ]; then
        echo "ERROR: No domain specified.";
        return 1;
    fi;

    local domain="${1}";
    echo "Testing ${domain}…";
    echo ""; # newline

    local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
        | openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

    if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
        local certText=$(echo "${tmp}" \
            | openssl x509 -text -noout 2>&1);
        echo "Common Name:";
        echo ""; # newline
        echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
        echo ""; # newline
        echo "Subject Alternative Name(s):";
        echo ""; # newline
        echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
            | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
        return 0;
    else
        echo "ERROR: Certificate not found.";
        return 1;
    fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the given location
v() {
    if [ $# -eq 0 ]; then
        vim .;
    else
        vim "$@";
    fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given location
o() {
    if [ $# -eq 0 ]; then
        open .;
    else
        open "$@";
    fi;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled
tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Podman file helper
podmaner() {
    if [ $# -eq 0 ]; then
        echo "Usage: podmaner <image_name>";
        return 1;
    fi;
    
    local image_name="$1";
    podman history --no-trunc "$image_name" | tac | tr -s ' ' | cut -d " " -f 5- | sed 's,^/bin/sh -c #(nop) ,,g' | sed 's,^/bin/sh -c,RUN,g' | sed 's, && ,\n  & ,g' | sed 's,\s*[0-9]*[\.]*[0-9]*\s*[kMG]*B\s*$,,g' | head -n +1;
}

# Mass application installer
install-apps() {
    local apps=("$@")
    for app in "${apps[@]}"; do
        echo "Installing $app..."
        brew install --cask "$app" 2>/dev/null || brew install "$app" 2>/dev/null || echo "Failed to install $app"
    done
}

# System cleanup function
system-cleanup() {
    echo "🧹 Performing system cleanup..."
    
    # Clear DNS cache
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    
    # Empty trash
    sudo rm -rfv /Volumes/*/.Trashes 2>/dev/null
    sudo rm -rfv ~/.Trash 2>/dev/null
    sudo rm -rfv /private/var/log/asl/*.asl 2>/dev/null
    
    # Clear system caches
    sudo rm -rf /System/Library/Caches/*
    sudo rm -rf /Library/Caches/*
    rm -rf ~/Library/Caches/*
    
    # Clean Homebrew
    if command -v brew >/dev/null 2>&1; then
        brew cleanup
        brew doctor
    fi
    
    # Clean Podman
    if command -v podman >/dev/null 2>&1; then
        podman system prune -af
    fi
    
    echo "✅ System cleanup complete!"
}

# Quick system info
sysinfo() {
    echo "🖥️  System Information:"
    echo "OS: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
    echo "Shell: $SHELL"
    echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
    echo "Memory: $(echo "$(sysctl -n hw.memsize) / 1024 / 1024 / 1024" | bc)GB"
    echo "Disk: $(df -h / | awk 'NR==2{printf "%s/%s (%s used)\n", $3,$2,$5}')"
}

# Port finder
port() {
    if [ $# -eq 0 ]; then
        echo "Usage: port <port_number>"
        return 1
    fi
    lsof -i :$1
}

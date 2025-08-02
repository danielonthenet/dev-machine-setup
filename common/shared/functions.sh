#!/bin/bash
# Shared functions for all platforms

# Simple calculator
calc() {
    local result="";
    result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')";
    if [[ "$result" == *.* ]]; then
        printf "$result" | sed -e 's/^\./0./' -e 's/^-\./-0./' -e 's/0*$//;s/\.$//';
    else
        printf "$result";
    fi;
    printf "\n";
}

# Create a new directory and enter it
mkd() {
    mkdir -p "$@" && cd "$_";
}

# Base64 encode
base64-encode() {
   echo -n "$@" | base64;
}

# Get weather
weather() {
    local location="${1:-}"
    curl -s "wttr.in/${location}?format=3"
}

# Git status for current directory
gs() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git status -sb
    else
        echo "Not a git repository"
    fi
}

# Podman cleanup
podman-cleanup() {
    echo "Cleaning up Podman..."
    podman system prune -af
    podman volume prune -f
}

# Kubernetes context switcher
kctx() {
    if [[ $# -eq 0 ]]; then
        kubectl config get-contexts
    else
        kubectl config use-context "$1"
    fi
}

# Find and kill process by name
killall-name() {
    ps aux | grep -i "$1" | grep -v grep | awk '{print $2}' | xargs kill -9
}

# Determine size of a file or total size of a directory
fs() {
    if du -b /dev/null > /dev/null 2>&1; then
        local arg=-sbh;
    else
        local arg=-sh;
    fi
    if [[ -n "$@" ]]; then
        du $arg -- "$@";
    else
        du $arg .[^.]* * 2>/dev/null;
    fi;
}

# Create a data URL from a file
dataurl() {
    local mimeType=$(file -b --mime-type "$1");
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8";
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Start an HTTP server from a directory
server() {
    local port="${1:-8000}";
    if command -v python3 >/dev/null 2>&1; then
        sleep 1 && open "http://localhost:${port}/" &
        python3 -m http.server "$port";
    elif command -v python >/dev/null 2>&1; then
        sleep 1 && open "http://localhost:${port}/" &
        python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
    fi
}

# Compare original and gzipped file size
gz() {
    local origsize=$(wc -c < "$1");
    local gzipsize=$(gzip -c "$1" | wc -c);
    local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l);
    printf "orig: %d bytes\n" "$origsize";
    printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio";
}

# UTF-8-encode a string of Unicode symbols
escape() {
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u);
    if [ -t 1 ]; then
        echo "";
    fi;
}

# Decode \x{ABCD}-style Unicode escape sequences
unidecode() {
    perl -e "binmode(STDOUT, ':utf8'); print \"$@\"";
    if [ -t 1 ]; then
        echo "";
    fi;
}

# Get a character's Unicode code point
codepoint() {
    perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))";
    if [ -t 1 ]; then
        echo "";
    fi;
}

# Version Manager Functions

# Install and set a Ruby version
ruby-install() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ruby-install <version>"
        echo "Available versions:"
        rbenv install -l | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -10
        return 1
    fi
    
    rbenv install "$1" && rbenv global "$1"
    gem install bundler
    rbenv rehash
}

# Install and set a Python version
python-install() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: python-install <version>"
        echo "Available versions:"
        pyenv install --list | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -10
        return 1
    fi
    
    pyenv install "$1" && pyenv global "$1"
    pip install --upgrade pip pipenv poetry
}

# Install and set a Go version
go-install() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: go-install <version|latest>"
        echo "Available versions:"
        g list
        return 1
    fi
    
    g install "$1" && g set "$1"
}

# Install and set a Node.js version
node-install() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: node-install <version|--lts|latest>"
        echo "Examples:"
        echo "  node-install --lts        # Install latest LTS"
        echo "  node-install 18.17.0     # Install specific version"
        echo "  node-install latest       # Install latest version"
        return 1
    fi
    
    if [[ "$1" == "latest" ]]; then
        nvm install node
        nvm use node
        nvm alias default node
    elif [[ "$1" == "--lts" ]]; then
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
    else
        nvm install "$1"
        nvm use "$1"
        nvm alias default "$1"
    fi
}

# Install and set a Terraform version
terraform-install() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: terraform-install <version|latest-stable>"
        echo "Example: terraform-install 1.5.0"
        echo "Example: terraform-install latest-stable"
        return 1
    fi
    
    if [[ "$1" == "latest-stable" ]]; then
        tfswitch --latest-stable
    else
        tfswitch "$1"
    fi
}

# Show current language versions
show-versions() {
    echo "📋 Current Language Versions:"
    echo "----------------------------"
    
    if command -v ruby >/dev/null 2>&1; then
        echo "Ruby:      $(ruby -v | cut -d' ' -f2)"
        if command -v rbenv >/dev/null 2>&1; then
            echo "  (rbenv:  $(rbenv version | cut -d' ' -f1))"
        fi
    else
        echo "Ruby:      not installed"
    fi
    
    if command -v python >/dev/null 2>&1; then
        echo "Python:    $(python --version | cut -d' ' -f2)"
        if command -v pyenv >/dev/null 2>&1; then
            echo "  (pyenv:  $(pyenv version | cut -d' ' -f1))"
        fi
    else
        echo "Python:    not installed"
    fi
    
    if command -v go >/dev/null 2>&1; then
        echo "Go:        $(go version | cut -d' ' -f3 | sed 's/go//')"
        if command -v g >/dev/null 2>&1; then
            echo "  (g:      $(g --version 2>/dev/null || echo 'unknown'))"
        fi
    else
        echo "Go:        not installed"
    fi
    
    if command -v terraform >/dev/null 2>&1; then
        echo "Terraform: $(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || terraform version | head -1 | cut -d' ' -f2)"
    else
        echo "Terraform: not installed"
    fi
    
    if command -v node >/dev/null 2>&1; then
        echo "Node.js:   $(node --version | sed 's/v//')"
        if command -v nvm >/dev/null 2>&1; then
            echo "  (nvm:    $(nvm current 2>/dev/null || echo 'not using nvm'))"
        fi
    else
        echo "Node.js:   not installed"
    fi
}

# Update all version managers
update-version-managers() {
    echo "🔄 Updating version managers..."
    
    # Update rbenv
    if command -v rbenv >/dev/null 2>&1; then
        echo "Updating rbenv..."
        if [[ "$DOTFILES_OS" == "macos" ]]; then
            brew upgrade rbenv ruby-build
        else
            cd ~/.rbenv && git pull
            cd ~/.rbenv/plugins/ruby-build && git pull
        fi
    fi
    
    # Update pyenv
    if command -v pyenv >/dev/null 2>&1; then
        echo "Updating pyenv..."
        if [[ "$DOTFILES_OS" == "macos" ]]; then
            brew upgrade pyenv
        else
            cd ~/.pyenv && git pull
        fi
    fi
    
    # Update g (go version manager)
    if command -v g >/dev/null 2>&1; then
        echo "Updating g..."
        curl -sSL https://git.io/g-install | sh -s
    fi
    
    # Update nvm
    if [[ -d "$NVM_DIR" ]]; then
        echo "Updating nvm..."
        if [[ "$DOTFILES_OS" == "macos" ]]; then
            brew upgrade nvm 2>/dev/null || echo "nvm not installed via brew, updating manually..."
            (cd "$NVM_DIR" && git fetch --tags origin && git checkout $(git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)))
        else
            (cd "$NVM_DIR" && git fetch --tags origin && git checkout $(git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)))
        fi
    fi
    
    # Update tfswitch
    if command -v tfswitch >/dev/null 2>&1; then
        echo "Updating tfswitch..."
        if [[ "$DOTFILES_OS" == "macos" ]]; then
            brew upgrade warrensbox/tap/tfswitch
        else
            curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash
        fi
    fi
    
    echo "✅ Version managers updated!"
}

# Quick setup for a project directory with language versions
project-setup() {
    local project_name="$1"
    local ruby_version="$2"
    local python_version="$3"
    local go_version="$4"
    local terraform_version="$5"
    
    if [[ -z "$project_name" ]]; then
        echo "Usage: project-setup <project_name> [ruby_version] [python_version] [go_version] [terraform_version]"
        return 1
    fi
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    # Set local versions if specified
    [[ -n "$ruby_version" && -x "$(command -v rbenv)" ]] && rbenv local "$ruby_version"
    [[ -n "$python_version" && -x "$(command -v pyenv)" ]] && pyenv local "$python_version"
    [[ -n "$terraform_version" ]] && echo "$terraform_version" > .terraform-version
    
    # Create basic project structure
    mkdir -p docs src tests
    touch README.md .gitignore
    
    echo "📁 Project '$project_name' created with language versions:"
    show-versions
}

# Quick health check
dotfiles-health() {
    echo "🏥 Running dotfiles health check..."
    
    # Check symlinks
    echo ""
    echo "📁 Symlink Status:"
    for file in ~/.zshrc ~/.gitconfig ~/.vimrc ~/.p10k.zsh; do
        if [[ -L "$file" ]]; then
            echo "✅ $file -> $(readlink "$file")"
        elif [[ -f "$file" ]]; then
            echo "⚠️  $file (exists but not symlinked)"
        else
            echo "❌ $file (missing)"
        fi
    done
    
    # Check version managers
    echo ""
    echo "🔧 Version Managers:"
    local managers=("rbenv" "pyenv" "nvm" "g" "tfswitch")
    for mgr in "${managers[@]}"; do
        if command -v "$mgr" &> /dev/null; then
            echo "✅ $mgr installed"
        else
            echo "⚠️  $mgr not found"
        fi
    done
    
    # Check shell
    echo ""
    echo "🐚 Shell Configuration:"
    if [[ "$SHELL" == */zsh ]]; then
        echo "✅ Using zsh: $SHELL"
    else
        echo "⚠️  Not using zsh: $SHELL"
    fi
    
    # Check Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "✅ Oh My Zsh installed"
    else
        echo "⚠️  Oh My Zsh not found"
    fi
    
    # Check PATH
    echo ""
    echo "🛤️  PATH Check:"
    local important_paths=("$HOME/.rbenv/bin" "$HOME/.pyenv/bin" "$HOME/.g/bin" "$HOME/go/bin")
    for path_entry in "${important_paths[@]}"; do
        if [[ ":$PATH:" == *":$path_entry:"* ]]; then
            echo "✅ $path_entry in PATH"
        else
            echo "⚠️  $path_entry missing from PATH"
        fi
    done
    
    # Check environment variables
    echo ""
    echo "🌍 Environment Variables:"
    local env_vars=("DOTFILES_DIR" "DOTFILES_OS" "DOTFILES_PLATFORM")
    for var in "${env_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            echo "✅ $var: ${!var}"
        else
            echo "⚠️  $var: not set"
        fi
    done
}

# Shell startup time profiler
zsh-profile() {
    local times=5
    local total=0
    
    echo "⏱️  Profiling zsh startup time..."
    
    for i in $(seq 1 $times); do
        local time=$( (time zsh -i -c exit) 2>&1 | grep real | awk '{print $2}' | sed 's/[^0-9.]//g')
        if [[ -n "$time" ]]; then
            total=$(echo "$total + $time" | bc -l 2>/dev/null || echo "$total")
            echo "Run $i: ${time}s"
        fi
    done
    
    if command -v bc >/dev/null 2>&1 && [[ -n "$total" && "$total" != "0" ]]; then
        local avg=$(echo "scale=3; $total / $times" | bc -l)
        echo "📊 Average zsh startup time: ${avg}s (over $times runs)"
        
        if (( $(echo "$avg > 1.0" | bc -l) )); then
            echo "⚠️  Startup time is slow (>1s). Consider:"
            echo "   • Using lazy loading for version managers"
            echo "   • Reducing plugins"
            echo "   • Profiling with 'zprof'"
        fi
    else
        echo "❌ Could not calculate average (bc not available or no valid times)"
    fi
}

# Quick dotfiles validation
dotfiles-quick-check() {
    echo "🔍 Quick dotfiles check..."
    
    # Check if in dotfiles directory
    if [[ -n "$DOTFILES_DIR" && -d "$DOTFILES_DIR" ]]; then
        echo "✅ Dotfiles directory: $DOTFILES_DIR"
    else
        echo "❌ DOTFILES_DIR not set or missing"
        return 1
    fi
    
    # Check if main files are symlinked
    local files=("~/.zshrc" "~/.gitconfig" "~/.vimrc")
    for file in "${files[@]}"; do
        local expanded_file="${file/#\~/$HOME}"
        if [[ -L "$expanded_file" ]]; then
            echo "✅ $file is symlinked"
        else
            echo "❌ $file is not symlinked"
        fi
    done
    
    # Check if version managers are available
    local managers=("rbenv" "pyenv" "nvm" "g")
    local available=0
    for mgr in "${managers[@]}"; do
        if command -v "$mgr" >/dev/null 2>&1; then
            ((available++))
        fi
    done
    
    echo "📦 Version managers available: $available/${#managers[@]}"
    
    if [[ $available -eq ${#managers[@]} ]]; then
        echo "🎉 All checks passed!"
    else
        echo "⚠️  Some issues found. Run 'dotfiles-health' for details."
    fi
}

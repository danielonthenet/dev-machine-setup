#!/bin/bash
# macOS-specific exports

# Homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Resolve Homebrew prefix at runtime (Apple Silicon: /opt/homebrew, Intel: /usr/local)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    _BREW_PREFIX="/opt/homebrew"
elif [[ -x "/usr/local/bin/brew" ]]; then
    _BREW_PREFIX="/usr/local"
elif command -v brew >/dev/null 2>&1; then
    _BREW_PREFIX="$(brew --prefix 2>/dev/null)"
else
    _BREW_PREFIX=""
fi

# PATH for macOS
if [[ -n "$_BREW_PREFIX" && -d "$_BREW_PREFIX/opt/postgresql@17/bin" ]]; then
    export PATH="$_BREW_PREFIX/opt/postgresql@17/bin:$PATH"
fi

# Google Cloud SDK — adds gcloud components (incl. gke-gcloud-auth-plugin) to PATH
if [[ -n "$_BREW_PREFIX" && -f "$_BREW_PREFIX/share/google-cloud-sdk/path.zsh.inc" ]]; then
    source "$_BREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
fi
if [[ -n "$_BREW_PREFIX" && -d "$_BREW_PREFIX/sbin" ]]; then
    export PATH="$_BREW_PREFIX/sbin:$PATH"
fi
if [[ -n "$_BREW_PREFIX" && -d "$_BREW_PREFIX/opt/coreutils/libexec/gnubin" ]]; then
    export PATH="$_BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
fi
if [[ -n "$_BREW_PREFIX" && -d "$_BREW_PREFIX/opt/python/libexec/bin" ]]; then
    export PATH="$_BREW_PREFIX/opt/python/libexec/bin:$PATH"
fi

# Default applications (if VS Code is available, use it, otherwise vim)
if command -v code >/dev/null 2>&1; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
else
    export EDITOR="vim"
    export VISUAL="vim"
fi
export BROWSER="open"

# Virtual environments
export WORKON_HOME=$HOME/VirtualEnvPython 
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages' 
export PIP_VIRTUALENV_BASE=$WORKON_HOME 
export PIP_RESPECT_VIRTUALENV=true

#!/bin/bash
# macOS-specific exports

# Homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# PATH for macOS
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

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

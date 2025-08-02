#!/bin/bash
# Linux/WSL-specific exports

# WSL display for GUI apps
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    export DISPLAY=$(ip route list default | awk '{print $3}'):0
    export LIBGL_ALWAYS_INDIRECT=1
    
    # Windows integration paths
    export PATH="$PATH:/mnt/c/Windows/System32"
    export PATH="$PATH:/mnt/c/Windows"
    export PATH="$PATH:/mnt/c/Program Files/Microsoft VS Code/bin"
fi

# PATH for Linux
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Default applications (if VS Code is available, use it, otherwise vim)
if command -v code >/dev/null 2>&1; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
else
    export EDITOR="vim"
    export VISUAL="vim"
fi

# WSL browser helper
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    export BROWSER="wslview"
else
    export BROWSER="xdg-open"
fi

# Virtual environments
export WORKON_HOME=$HOME/VirtualEnvPython 
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages' 
export PIP_VIRTUALENV_BASE=$WORKON_HOME 
export PIP_RESPECT_VIRTUALENV=true

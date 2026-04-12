#!/bin/bash
# Lazy loading for version managers to improve shell startup performance

# Initialize rbenv immediately (not lazy-loaded)
# rbenv needs shims in PATH for automatic version switching
if [[ -d "$HOME/.rbenv" ]]; then
    export PATH="$HOME/.rbenv/shims:$PATH"
    # Note: Full rbenv init not needed - just shims in PATH is sufficient
    # for automatic version switching via shims
fi

# Initialize goenv shims immediately (similar to rbenv)
# goenv needs shims in PATH for automatic version switching
if [[ -d "$HOME/.goenv" ]]; then
    export PATH="$HOME/.goenv/shims:$PATH"
    # Note: Full goenv init not needed - just shims in PATH is sufficient
    # for automatic version switching via shims
fi

lazy_load_brew_prefix() {
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        echo "/opt/homebrew"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        echo "/usr/local"
    elif command -v brew >/dev/null 2>&1; then
        brew --prefix 2>/dev/null
    fi
}

find_executable_on_path() {
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        whence -p "$1" 2>/dev/null
    else
        type -P "$1" 2>/dev/null
    fi
}

# Lazy load pyenv
pyenv() {
    if [[ -d "$HOME/.pyenv" ]]; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(command pyenv init -)"
        # Load pyenv-virtualenv if available
        if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
            eval "$(pyenv virtualenv-init -)"
        fi
        unfunction pyenv
        pyenv "$@"
    else
        echo "pyenv not installed"
        return 1
    fi
}

# Lazy load nvm
nvm() {
    if [[ -d "$NVM_DIR" ]]; then
        local brew_prefix=""
        brew_prefix="$(lazy_load_brew_prefix)"
        if [[ "$DOTFILES_OS" == "macos" && -n "$brew_prefix" && -d "$brew_prefix/opt/nvm" ]]; then
            [ -s "$brew_prefix/opt/nvm/nvm.sh" ] && \. "$brew_prefix/opt/nvm/nvm.sh"
            [ -s "$brew_prefix/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$brew_prefix/opt/nvm/etc/bash_completion.d/nvm"
        else
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        fi
        unfunction nvm
        nvm "$@"
    else
        echo "nvm not installed"
        return 1
    fi
}

# Lazy load goenv
goenv() {
    if [[ -d "$HOME/.goenv" ]]; then
        export GOENV_ROOT="$HOME/.goenv"
        export PATH="$GOENV_ROOT/bin:$PATH"
        eval "$(command goenv init -)"
        export GOPATH="$HOME/go"
        export PATH="$GOPATH/bin:$PATH"
        unfunction goenv
        goenv "$@"
    else
        echo "goenv not installed"
        return 1
    fi
}

# Note: tfswitch doesn't need lazy loading as it's just a binary without heavy initialization

# Lazy load SDKMAN! (Java version manager)
sdk() {
    if [[ -d "$HOME/.sdkman" ]]; then
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
        unfunction sdk
        sdk "$@"
    else
        echo "SDKMAN! not installed. Install with: curl -s 'https://get.sdkman.io' | bash"
        return 1
    fi
}

# Also lazy load java command to trigger SDKMAN! init
java() {
    if [[ -d "$HOME/.sdkman" ]]; then
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
        unfunction java 2>/dev/null
        java "$@"
    else
        # Preserve whatever real java is already on PATH when SDKMAN is absent.
        local java_cmd=""
        java_cmd="$(find_executable_on_path java || true)"
        if [[ -n "$java_cmd" ]]; then
            unfunction java 2>/dev/null
            "$java_cmd" "$@"
        else
            echo "Java not installed. Install with: sdk install java"
            return 1
        fi
    fi
}

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
        if [[ "$DOTFILES_OS" == "macos" && -d "/opt/homebrew/opt/nvm" ]]; then
            [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
            [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
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

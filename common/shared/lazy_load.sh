#!/bin/bash
# Lazy loading for version managers to improve shell startup performance

# Lazy load rbenv
rbenv() {
    if [[ -d "$HOME/.rbenv" ]]; then
        export PATH="$HOME/.rbenv/bin:$PATH"
        eval "$(command rbenv init -)"
        unfunction rbenv
        rbenv "$@"
    else
        echo "rbenv not installed"
        return 1
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

# Lazy load g (go version manager) - use go-version to avoid conflict with git alias
load_go_version_manager() {
    if command -v /usr/local/bin/g >/dev/null 2>&1 || command -v ~/.g/bin/g >/dev/null 2>&1; then
        export GOPATH="$HOME/go"
        export GOROOT="$HOME/.g/go"
        export PATH="$HOME/.g/bin:$PATH"
        export PATH="$GOPATH/bin:$PATH"
        
        # Remove this loader function and call the actual g command
        unfunction load_go_version_manager
        
        # Call g with original arguments  
        if command -v ~/.g/bin/g >/dev/null 2>&1; then
            ~/.g/bin/g "$@"
        else
            /usr/local/bin/g "$@"
        fi
    else
        echo "g (go version manager) not installed"
        return 1
    fi
}

# Use go-version alias to avoid conflict with git alias 'g'
alias go-version='load_go_version_manager'

# Note: tfswitch doesn't need lazy loading as it's just a binary without heavy initialization

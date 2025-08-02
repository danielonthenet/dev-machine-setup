# Universal .zshrc that works on both macOS and Linux/WSL

# Get dotfiles directory - handle both symlinks and direct files
if [[ -L "${(%):-%x}" ]]; then
    # If .zshrc is a symlink, get the real path and go up one directory from common
    DOTFILES_DIR="$(cd "$(dirname "$(readlink "${(%):-%x}")")/.." && pwd)"
else
    # If .zshrc is not a symlink, go up one directory from common
    DOTFILES_DIR="$(cd "$(dirname "${(%):-%x}")/.." && pwd)"
fi

# Source OS detection
source "$DOTFILES_DIR/common/detect_os.sh"

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# History configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Base plugins (common to all platforms)
base_plugins=(
    git
    podman
    kubectl
    aws
    terraform
    fzf
    zsh-syntax-highlighting
    zsh-autosuggestions
    python
    pip
    virtualenv
)

# Platform-specific plugins
case "$DOTFILES_OS" in
    "macos")
        platform_plugins=(brew macos)
        ;;
    "linux")
        platform_plugins=(ubuntu)
        if [[ -n "$WSL_DISTRO_NAME" ]]; then
            platform_plugins+=(wsl)
        fi
        ;;
esac

# Combine plugins
plugins=($base_plugins $platform_plugins)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load shared configuration first
source "$DOTFILES_COMMON_DIR/shared/exports.sh"
source "$DOTFILES_COMMON_DIR/shared/functions.sh"
source "$DOTFILES_COMMON_DIR/shared/aliases.sh"
source "$DOTFILES_COMMON_DIR/shared/lazy_load.sh"

# Load platform-specific configuration
if [[ -d "$DOTFILES_OS_DIR" ]]; then
    source "$DOTFILES_OS_DIR/exports.sh"
    source "$DOTFILES_OS_DIR/functions.sh"
    source "$DOTFILES_OS_DIR/aliases.sh"
fi

# Load third-party integrations
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/.kubectl_aliases ]] && source ~/.kubectl_aliases
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Platform-specific integrations
case "$DOTFILES_PLATFORM" in
    "macos")
        # macOS-specific integrations
        [[ -s $(brew --prefix)/etc/autojump.sh ]] && source $(brew --prefix)/etc/autojump.sh
        
        # NVM setup for macOS
        export NVM_DIR="$HOME/.nvm"
        if [[ -d "/opt/homebrew/opt/nvm" ]]; then
            [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
            [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
        fi
        
        # iTerm2 integration
        test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
        ;;
    "wsl"|"linux")
        # Linux/WSL-specific integrations
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        ;;
esac

# Auto-completion
autoload -U +X bashcompinit && bashcompinit
command -v vault >/dev/null 2>&1 && complete -o nospace -C $(command -v vault) vault
command -v terraform >/dev/null 2>&1 && complete -o nospace -C $(command -v terraform) terraform

# Note: Version managers are now lazy-loaded for better performance
# They will be initialized when first used

# Enable completions
if [[ -d /usr/local/share/zsh-completions ]]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi

# Enable case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob 2>/dev/null

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null;
done;

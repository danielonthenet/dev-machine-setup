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

dotfiles_brew_prefix() {
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        echo "/opt/homebrew"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        echo "/usr/local"
    elif command -v brew >/dev/null 2>&1; then
        brew --prefix 2>/dev/null
    fi
}

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# History configuration - large but reasonable limits
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=500000               # Maximum events in memory (500K)
export SAVEHIST=500000               # Maximum events in history file (500K)
setopt APPEND_HISTORY                # Append rather than overwrite
setopt INC_APPEND_HISTORY            # Write to history file immediately
setopt SHARE_HISTORY                 # Share history between sessions
setopt EXTENDED_HISTORY              # Record timestamp of command
setopt HIST_IGNORE_DUPS              # Don't record duplicate consecutive commands
setopt HIST_IGNORE_ALL_DUPS          # Remove older duplicate commands from history
setopt HIST_IGNORE_SPACE             # Don't record commands starting with space
setopt HIST_FIND_NO_DUPS             # Don't display duplicates when searching
setopt HIST_SAVE_NO_DUPS             # Don't write duplicates to history file
setopt HIST_REDUCE_BLANKS            # Remove superfluous blanks before recording
setopt HIST_EXPIRE_DUPS_FIRST        # Expire duplicates first when trimming

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

DOTFILES_BREW_PREFIX="${_BREW_PREFIX:-$(dotfiles_brew_prefix)}"

# Load third-party integrations
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/.kubectl_aliases ]] && source ~/.kubectl_aliases
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Platform-specific integrations
case "$DOTFILES_PLATFORM" in
    "macos")
        # macOS-specific integrations
        [[ -n "$DOTFILES_BREW_PREFIX" && -s "$DOTFILES_BREW_PREFIX/etc/autojump.sh" ]] && source "$DOTFILES_BREW_PREFIX/etc/autojump.sh"
        
        # NVM setup for macOS
        export NVM_DIR="$HOME/.nvm"
        if [[ -n "$DOTFILES_BREW_PREFIX" && -d "$DOTFILES_BREW_PREFIX/opt/nvm" ]]; then
            [ -s "$DOTFILES_BREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$DOTFILES_BREW_PREFIX/opt/nvm/nvm.sh"
            [ -s "$DOTFILES_BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$DOTFILES_BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
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
command -v vault >/dev/null 2>&1 && complete -o nospace -C "$(command -v vault)" vault
command -v terraform >/dev/null 2>&1 && complete -o nospace -C "$(command -v terraform)" terraform

# Note: Version managers are now lazy-loaded for better performance
# They will be initialized when first used

# Enable completions
if [[ -n "$DOTFILES_BREW_PREFIX" && -d "$DOTFILES_BREW_PREFIX/share/zsh-completions" ]]; then
    fpath=("$DOTFILES_BREW_PREFIX/share/zsh-completions" $fpath)
elif [[ -d /usr/local/share/zsh-completions ]]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi

# Enable case-insensitive globbing (used in pathname expansion)
setopt NO_CASE_GLOB 2>/dev/null

# Enable zsh features:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
setopt AUTO_CD 2>/dev/null
setopt GLOB_STAR_SHORT 2>/dev/null

# Source work-specific configurations (if exists)
[[ -f "$HOME/.zshrc.custom" ]] && source "$HOME/.zshrc.custom"

# Auto-discover and source custom-* directory configs
# This allows for custom-work, custom-company1, custom-company2, etc.
for custom_dir in "$DOTFILES_DIR"/custom-*/; do
    if [[ -d "$custom_dir" ]]; then
        [[ -f "$custom_dir/functions.sh" ]] && source "$custom_dir/functions.sh"
        [[ -f "$custom_dir/aliases.sh" ]] && source "$custom_dir/aliases.sh"
    fi
done

# Disable mouse in Claude Code
export CLAUDE_CODE_DISABLE_MOUSE_CLICKS=1

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

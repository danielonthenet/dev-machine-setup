# Quick Reference

Daily commands and shortcuts for your development environment.

## Version Managers

All version managers load automatically when you use them.

### Node.js (nvm)
```bash
nvm install 18        # Install Node.js 18
nvm install --lts     # Install latest LTS
nvm use 16           # Switch to version 16
nvm list             # List installed versions
ni 18                # Shortcut: nvm install 18
nu 18                # Shortcut: nvm use 18
```

### Python (pyenv)
```bash
pyenv install 3.11.0 # Install Python 3.11.0
pyenv global 3.11.0  # Set global version
pyenv local 3.10.0   # Set version for current project
pyenv versions       # List installed versions
pyi 3.11             # Shortcut: pyenv install 3.11
pyg 3.11             # Shortcut: pyenv global 3.11
```

### Ruby (rbenv)
```bash
rbenv install 3.2.0  # Install Ruby 3.2.0
rbenv global 3.2.0   # Set global version
rbenv local 3.1.0    # Set version for current project
rbenv versions       # List installed versions
rbi 3.2              # Shortcut: rbenv install 3.2
rbg 3.2              # Shortcut: rbenv global 3.2
```

### Go (g)
```bash
g install 1.21.0     # Install Go 1.21.0
g set 1.21.0         # Switch to version
g list               # List installed versions
```

### Terraform (tfswitch)
```bash
tfswitch             # Interactive version selection
tfswitch 1.6.0       # Switch to specific version
```

## Project Setup

Set specific language versions for a project:

```bash
cd myproject

# Create version files
echo "18.17.0" > .nvmrc              # Node.js version
echo "3.11.0" > .python-version     # Python version  
echo "3.2.0" > .ruby-version        # Ruby version
echo "1.6.0" > .terraform-version   # Terraform version

# Version managers will auto-use these when you cd into the directory
```

## Modern CLI Tools

```bash
# File operations
exa -la              # Better ls with git status
exa --tree           # Directory tree view
bat file.txt         # Better cat with syntax highlighting
fd pattern           # Better find
rg "search"          # Better grep (ripgrep)

# System monitoring
htop                 # Better top
dust                 # Better du (disk usage)
duf                  # Better df (filesystem info)
```

## Git Shortcuts

```bash
g status             # git status  
gaa                  # git add --all
gcm "message"        # git commit -m "message"
gp                   # git push
gl                   # git pull
glog                 # git log --oneline --graph
```

## Container Tools

```bash
# Podman (Docker alternative)
podman ps            # List containers
podman images        # List images
dps                  # Formatted podman ps
dclean               # Clean up unused containers/images
```

## Utility Functions

```bash
# Directory operations
mkd myproject        # Create directory and cd into it
backup file.txt      # Create timestamped backup
extract archive.zip  # Extract any archive format

# Network and system
myip                 # Show public IP address
weather [city]       # Get weather info
calc 2+2*3          # Calculator
qr "text"           # Generate QR code

# Development
server 8080         # Start HTTP server on port 8080
json-pretty         # Format JSON from clipboard
```

## Health and Maintenance

```bash
# Check system health
dotfiles-health      # Comprehensive health check
dotfiles-quick-check # Quick validation

# Dotfiles management
dotfiles-update      # Update dotfiles from repository
dotfiles-backup      # Backup current configuration
dotfiles-status      # Check git status of dotfiles
./common/setup_dotfiles.sh           # Reinstall dotfiles
./common/setup_dotfiles.sh validate  # Validate installation
./common/setup_dotfiles.sh backup    # Backup existing files

# Updates  
update-system        # Update system packages
update-version-managers # Update all version managers

# Performance
zsh-profile          # Measure shell startup time
reload               # Reload shell configuration
exec zsh             # Restart shell
```

## Utility Commands

```bash
# Show current versions
versions              # Show all current language versions
show-versions         # Detailed version info

# Theme configuration
p10k configure       # Reconfigure Powerlevel10k theme

# Platform-specific (macOS)
show                 # Show hidden files in Finder
hide                 # Hide hidden files in Finder
o .                  # Open current directory in Finder
flush                # Flush DNS cache

# Platform-specific (Linux/WSL)
open .               # Open in file manager
explorer .           # Open Windows Explorer (WSL only)
sysinfo              # Show system information
```

## Troubleshooting

```bash
# If commands don't work
source ~/.zshrc      # Reload configuration
exec zsh             # Restart shell

# If version managers aren't found
echo $PATH | tr ':' '\n' | grep -E "(nvm|pyenv|rbenv)"
validate-version-managers

# Check what's installed
which nvm pyenv rbenv g tfswitch

# Run diagnostics
dotfiles-health
validate-version-managers
```

## File Locations

```bash
~/.zshrc             # Main shell configuration
~/.dotfiles/         # Dotfiles repository  
~/.p10k.zsh          # Powerlevel10k theme config

# Setup logs
~/.dev-machine-setup.log    # Setup log (macOS/Windows)
~/.setup-linux.log          # Setup log (Linux)
~/.dotfiles-install.log     # Dotfiles installation log
```

# Dev Machine Setup

Set up your development environment with one command. Works on macOS, Linux, and Windows with WSL2.

## Quick Start

**macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/danielonthenet/dev-machine-setup/main/setup_mac.sh | bash
```

**Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/danielonthenet/dev-machine-setup/main/setup_linux.sh | bash
```

**Windows (PowerShell as Admin):**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/danielonthenet/dev-machine-setup/main/setup_windows.ps1'))
```

## What Gets Installed

**Version Managers:**
- Node.js (nvm), Python (pyenv), Ruby (rbenv), Go (g), Terraform (tfswitch)

**Development Tools:**
- Git, Docker/Podman, modern CLI tools (exa, bat, fd, ripgrep, etc.)
- Zsh with Oh My Zsh and Powerlevel10k theme
- Platform package managers (Homebrew, apt/yum, Chocolatey)

Complete package lists are in: `macos/packages.sh`, `linux/packages.sh`, `windows/packages.ps1`

## Setup Process

1. **Run the installation script** (see Quick Start above)
2. **Windows only**: After WSL2 installs, run the Linux setup inside WSL
3. **Restart your terminal** or run `exec zsh`
4. **Configure the theme** with `p10k configure`
5. **Verify installation** with `dotfiles-health`

## Essential Commands

**Version Management:**
```bash
nvm install 18        # Install Node.js 18
pyenv install 3.11    # Install Python 3.11
rbenv install 3.2     # Install Ruby 3.2
g install 1.21        # Install Go 1.21
tfswitch             # Select Terraform version
```

**Project Setup:**
```bash
# Set project versions
echo "18" > .nvmrc
echo "3.11" > .python-version
echo "3.2" > .ruby-version
```

**Daily Tools:**
```bash
exa -la              # Better ls
bat file.txt         # Better cat with syntax highlighting
fd pattern           # Better find
rg "search"          # Better grep
```

**Maintenance:**
```bash
dotfiles-health      # System health check
update-system        # Update packages
reload               # Reload shell config
```



## macOS-Style Shortcut Keys (Kinto)

When you enable macOS-style keyboard shortcuts with Kinto, you get familiar macOS key mappings on Windows:

| Shortcut           | Action                        |
|--------------------|-------------------------------|
| Cmd+C              | Copy                          |
| Cmd+V              | Paste                         |
| Cmd+X              | Cut                           |
| Cmd+Z              | Undo                          |
| Cmd+Shift+Z        | Redo                          |
| Cmd+A              | Select All                    |
| Cmd+F              | Find                          |
| Cmd+S              | Save                          |
| Cmd+Q              | Quit/Close Window             |
| Cmd+W              | Close Tab/Window              |
| Cmd+Tab            | Switch Applications           |
| Cmd+`              | Switch Windows (same app)     |
| Cmd+Space          | Search/Spotlight              |
| Cmd+Shift+3        | Screenshot (full screen)      |
| Cmd+Shift+4        | Screenshot (selection)        |
| Cmd+Shift+N        | New Folder (Explorer/Finder)  |
| Cmd+Shift+T        | Reopen Closed Tab             |
| Cmd+Left/Right     | Jump to Line Start/End        |
| Cmd+Up/Down        | Jump to Document Start/End    |
| Cmd+Backspace      | Delete Line                   |
| Cmd+L              | Focus Address Bar (Browser)   |
| Cmd+R              | Refresh/Reload                |
| Cmd+T              | New Tab                       |
| Cmd+N              | New Window                    |
| Cmd+O              | Open File                     |
| Cmd+P              | Print                         |
| Cmd+E              | Search in File/Folder         |
| Cmd+D              | Bookmark/Add to Favorites     |
| Cmd+Shift+Delete   | Empty Trash/Clear History     |

These shortcuts work across most Windows applications, browsers, and editors, making it easier for Mac users to transition and maintain productivity. Some shortcuts may depend on the application and Kinto's configuration.

For complete command reference, see [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

## Manual Installation

```bash
git clone https://github.com/danielonthenet/dev-machine-setup.git
cd dev-machine-setup
./setup_mac.sh     # macOS
./setup_linux.sh   # Linux
.\setup_windows.ps1 # Windows (PowerShell as Admin)
```

## Troubleshooting

**Commands not found?**
```bash
exec zsh             # Restart shell
source ~/.zshrc      # Reload config
```

**Version managers not working?**
```bash
echo $PATH | tr ':' '\n' | grep -E "(nvm|pyenv|rbenv)"
validate-version-managers
```

**Need help?**
- Run `dotfiles-health` for diagnostics
- Check logs: `~/.dev-machine-setup.log` (macOS/Windows) or `~/.setup-linux.log` (Linux)
- Validate installation: `./validate_installation.sh`

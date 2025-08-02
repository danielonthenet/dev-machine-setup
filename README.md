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

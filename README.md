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
- Git, Docker/Podman, Kubernetes management (Freelens, Headlamp)
- Modern CLI tools (exa, bat, fd, ripgrep, etc.)
- Zsh with Oh My Zsh and Powerlevel10k theme
- Platform package managers (Homebrew, apt/yum, Chocolatey)
- Kubernetes: kubectl, helm, kubeconform (manifest validation)
- YAML tools: yq (processor), yamale (schema validator)

**AWS Authentication:**
- Leapp desktop app and CLI for secure AWS credential management
- Supports IAM users, federated roles, and AWS SSO

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

## Cloud SQL Proxy

Securely connect to Google Cloud SQL instances without IP whitelisting or SSL configuration. Available as an optional installation during setup.

**Quick Install:**
- Select option 4 (Custom) during setup and answer 'y' when prompted
- Or install manually: `source macos/packages.sh && install_cloud_sql_proxy` (macOS) or `source linux/packages.sh && install_cloud_sql_proxy` (Linux)

**Basic Usage:**
```bash
cloud-sql-proxy project:region:instance    # Connect to instance
cloud-sql-proxy --version                  # Check version
```

For detailed usage, authentication, and troubleshooting, see [docs/CLOUD_SQL_PROXY.md](docs/CLOUD_SQL_PROXY.md)

## AWS Authentication with Leapp

Leapp provides secure, temporary AWS credential management with support for multiple AWS accounts and authentication methods.

### Platform-Specific Setup

**macOS:**
- Desktop app: Installed via Homebrew Cask (`leapp`)
- CLI: Architecture-specific installation (Intel/ARM64) via Homebrew

**Windows + WSL:**
- Desktop app: Installed on Windows via winget (`Noovolari.Leapp`)
- CLI: Installed in WSL via Homebrew/Linuxbrew
- The Windows desktop app handles authentication for both Windows and WSL environments

**Linux (Desktop):**
- Desktop app: Manual installation from [Leapp releases](https://www.leapp.cloud/releases)
- CLI: Installed via Homebrew/Linuxbrew

### Getting Started with Leapp

1. **Launch the desktop app** (required for CLI to work)
2. **Configure your first session:**
   ```bash
   leapp session add    # Add AWS account/role
   ```
3. **Start a session:**
   ```bash
   leapp session start <session-name>
   ```
4. **Use AWS CLI normally:**
   ```bash
   aws s3 ls           # Credentials automatically available
   ```

### Key Features

- **Temporary credentials**: Automatic rotation and secure storage
- **Multiple accounts**: Switch between AWS accounts seamlessly  
- **SSO integration**: Support for AWS Single Sign-On
- **Role chaining**: Assume roles across accounts
- **Zero-config AWS CLI**: Credentials automatically available to aws-cli

### Important Notes

- **Desktop app dependency**: The CLI requires the desktop app to be running
- **WSL compatibility**: Windows Leapp desktop app works with WSL CLI
- **Credential isolation**: Each session provides isolated, temporary credentials
- **Auto-refresh**: Credentials are automatically refreshed when needed

## Claude Code Sleep Prevention Hooks (macOS)

When using Claude Code on macOS, you can prevent your Mac from sleeping while Claude is working. This is especially useful when running long tasks and you step away from your computer.

### What It Does

- **Automatically prevents sleep** when Claude Code starts processing your requests
- **Re-enables sleep** when Claude Code finishes or is stopped
- **Works for up to 1 hour** per session (automatically times out for safety)

### Setup

During dotfiles installation, you'll be prompted to install Claude Code sleep prevention hooks. If you want to install them manually:

1. **Copy hook scripts:**
   ```bash
   mkdir -p ~/.claude/hooks
   cp common/claude_hooks/prevent-sleep.sh ~/.claude/hooks/
   cp common/claude_hooks/allow-sleep.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/*.sh
   ```

2. **Configure Claude Code settings:**
   Add to `~/.claude/settings.json`:
   ```json
   "hooks": {
     "Stop": [
       {
         "hooks": [
           {
             "type": "command",
             "command": "$HOME/.claude/hooks/allow-sleep.sh"
           }
         ]
       }
     ],
     "UserPromptSubmit": [
       {
         "hooks": [
           {
             "type": "command",
             "command": "$HOME/.claude/hooks/prevent-sleep.sh"
           }
         ]
       }
     ]
   }
   ```

3. **Restart Claude Code** for the hooks to take effect

### How It Works

- Uses macOS's `caffeinate` command to temporarily prevent system sleep
- Automatically cleans up if multiple sessions are started
- Only prevents idle sleep (display can still sleep)
- Safe timeout after 1 hour to prevent indefinite wake

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

## Work-Specific Configurations (custom-* Pattern)

If you need to add company-specific or work-related configurations (SSL certificates, corporate proxies, internal tools), use the `custom-*` pattern to keep them separate from your personal setup.

### Quick Setup

1. **Create a custom directory** for your work configs:
   ```bash
   mkdir custom-work
   ```

2. **Add your work-specific shell functions and aliases:**
   ```bash
   # custom-work/functions.sh - Work-specific functions
   # custom-work/aliases.sh - Work-specific aliases
   ```

3. **Create `~/.zshrc.custom`** for environment variables:
   ```bash
   # ~/.zshrc.custom
   export SSL_CERT_FILE=$HOME/certs/company-ca-bundle.pem
   export INTERNAL_TOOL_PATH="/opt/company-tools"
   ```

4. **Reload your shell:**
   ```bash
   exec zsh
   ```

### How It Works

- `custom-*` directories are automatically gitignored (won't be committed)
- Functions and aliases from `custom-*/functions.sh` and `custom-*/aliases.sh` are auto-loaded
- `~/.zshrc.custom` is sourced automatically for environment variables
- Use `common/.zshrc.custom.template` as a starting point

### Backup and Restore

**Backup your work configs:**
```bash
# Copy template and customize for your setup
cp custom-sync_work_configs_to_drive.sh.template custom-sync_work_configs_to_drive.sh
# Edit the script with your backup location (Google Drive, Dropbox, etc.)
# Then run it to backup
./custom-sync_work_configs_to_drive.sh
```

**Restore on a new machine:**
```bash
# Customize setup_work_configs.sh with your backup location
./setup_work_configs.sh
```

### Example Structure

```
dev-machine-setup/
├── custom-mycompany/           # Work configs (gitignored)
│   ├── functions.sh           # Work functions
│   ├── aliases.sh             # Work aliases
│   └── setup_custom.sh        # Work-specific setup script
├── custom-proxy-config.sh     # Corporate proxy setup (gitignored)
└── ~/.zshrc.custom            # Work environment variables (gitignored)
```

This pattern keeps your fork clean and makes it easy to maintain both personal and work configurations.

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

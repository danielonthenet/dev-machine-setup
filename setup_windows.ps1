# Windows Development Machine Setup
# Complete automation for setting up a development environment on Windows 11 with WSL2
# Now uses modular structure with windows/ directory for better organization

[CmdletBinding()]
param(
    [switch]$FullSetup,
    [switch]$WindowsOnly,
    [switch]$WSLOnly,
    [switch]$SkipReboot,
    [string]$WSLPath = "D:\WSL",
    [string]$Username = $env:USERNAME
)

# Get script directory
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green" 
    Yellow = "Yellow"
    Blue = "Cyan"
    Purple = "Magenta"
    White = "White"
}

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path "$env:USERPROFILE\.dev-machine-setup.log" -Value $logMessage
}

# Welcome message
function Show-Welcome {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor $Colors.Blue
    Write-Host "                  Windows Dev Machine Setup                    " -ForegroundColor $Colors.Blue
    Write-Host "            Complete Development Environment                    " -ForegroundColor $Colors.Blue
    Write-Host "                  Windows 11 + WSL2 + Ubuntu                   " -ForegroundColor $Colors.Blue
    Write-Host "================================================================" -ForegroundColor $Colors.Blue
    Write-Host ""
}

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Load Windows-specific modules
function Import-WindowsModules {
    Write-Log "Loading Windows-specific modules..."
    
    $packagesPath = Join-Path $SETUP_DIR "windows\packages.ps1"
    $setupPath = Join-Path $SETUP_DIR "windows\setup_windows.ps1"
    
    if (Test-Path $packagesPath) {
        . $packagesPath
        Write-Log "SUCCESS: Windows packages module loaded"
    } else {
        Write-Log "WARNING: Windows packages module not found: $packagesPath" -Level "WARN"
    }
    
    if (Test-Path $setupPath) {
        . $setupPath
        Write-Log "SUCCESS: Windows setup module loaded"
    } else {
        Write-Log "WARNING: Windows setup module not found: $setupPath" -Level "WARN"
    }
}

# Check prerequisites
function Test-Prerequisites {
    Write-Log "Checking prerequisites..."
    
    # Check Windows version
    $osVersion = [System.Environment]::OSVersion.Version
    $buildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
    Write-Log "Windows Version: $($osVersion.Major).$($osVersion.Minor) Build: $buildNumber"
    
    if ($osVersion.Major -lt 10) {
        Write-Host "ERROR: Windows 10 or later is required" -ForegroundColor $Colors.Red
        exit 1
    }
    
    # Check if running as Administrator
    if (-not (Test-Administrator)) {
        Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor $Colors.Red
        Write-Host "Right-click PowerShell and 'Run as Administrator'" -ForegroundColor $Colors.Yellow
        exit 1
    }
    
    # Check available disk space
    $systemDrive = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    $freeSpaceGB = [math]::Round($systemDrive.FreeSpace / 1GB, 2)
    
    if ($freeSpaceGB -lt 10) {
        Write-Host "WARNING: Low disk space on C: drive - $freeSpaceGB GB available" -ForegroundColor $Colors.Yellow
        $continue = Read-Host "Continue anyway? [y/N]"
        if ($continue -notmatch "^[Yy]$") {
            exit 1
        }
    }
    
    Write-Log "SUCCESS: Prerequisites check passed"
    return $true
}

# Install Chocolatey
function Install-Chocolatey {
    Write-Log "Installing Chocolatey package manager..."
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Log "SUCCESS: Chocolatey already installed"
        choco upgrade chocolatey -y
        return
    }
    
    Write-Host "Installing Chocolatey..." -ForegroundColor $Colors.Blue
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh environment variables
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path","User")
    $env:Path = $machinePath + ";" + $userPath
    
    Write-Log "SUCCESS: Chocolatey installed successfully"
}

# Install Windows packages
function Install-WindowsPackages {
    Write-Log "Installing Windows packages..."
    
    # Use the modular packages from windows/packages.ps1
    if (Get-Command Install-InteractivePackages -ErrorAction SilentlyContinue) {
        Install-InteractivePackages
    } else {
        Write-Host "WARNING: Install-InteractivePackages function not found. Skipping Windows package installation." -ForegroundColor Yellow
    }
}

# Enable Windows features for development
function Enable-WindowsFeatures {
    Write-Log "Enabling Windows features..."
    
    $features = @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform"
    )
    
    $rebootRequired = $false
    
    foreach ($feature in $features) {
        try {
            $featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction Stop
            if ($featureState.State -eq "Disabled") {
                Write-Log "Enabling $feature..."
                $result = Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
                if ($result.RestartNeeded) {
                    $rebootRequired = $true
                }
                Write-Log "SUCCESS: $feature enabled"
            } else {
                Write-Log "SUCCESS: $feature already enabled"
            }
        } catch {
            Write-Log "WARNING: Could not check/enable feature $feature - $($_.Exception.Message)" -Level "WARN"
        }
    }
    
    # Enable Hyper-V if supported (optional)
    try {
        $hyperV = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -ErrorAction Stop
        if ($hyperV -and $hyperV.State -eq "Disabled") {
            Write-Log "Enabling Hyper-V..."
            $result = Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -All -NoRestart
            if ($result.RestartNeeded) {
                $rebootRequired = $true
            }
            Write-Log "SUCCESS: Hyper-V enabled"
        } elseif ($hyperV) {
            Write-Log "SUCCESS: Hyper-V already enabled"
        }
    } catch {
        Write-Log "INFO: Hyper-V not available on this system (expected on Home editions)" -Level "INFO"
    }
    
    if ($rebootRequired) {
        Write-Log "WARNING: Reboot required to complete Windows feature installation"
    }
    
    return $rebootRequired
}

# Install and configure WSL2
function Install-WSL {
    Write-Log "Setting up WSL2 with Ubuntu..."
    
    # Update WSL to latest version first
    Write-Host "Updating WSL to latest version..." -ForegroundColor $Colors.Blue
    try {
        wsl --update
        Write-Log "SUCCESS: WSL updated to latest version"
    } catch {
        Write-Log "WARNING: WSL update failed, continuing anyway..." -Level "WARN"
    }
    
    # Set WSL2 as default version
    wsl --set-default-version 2
    
    # Check if any Ubuntu distribution is already installed
    $ubuntuInstalled = $false
    try {
        # Use wsl --list --verbose which has cleaner output
        $wslOutput = wsl --list --verbose 2>$null
        if ($wslOutput -and ($wslOutput | Select-String "Ubuntu")) {
            $ubuntuInstalled = $true
            Write-Log "SUCCESS: Ubuntu distribution already installed"
        }
    } catch {
        Write-Log "Checking for existing Ubuntu installations..."
    }
    
    # Check if any Ubuntu distribution is already installed
    $ubuntuInstalled = $false
    try {
        $wslList = wsl --list --quiet 2>$null
        if ($wslList -and ($wslList | Select-String "Ubuntu")) {
            $ubuntuInstalled = $true
            $existingDistro = $wslList | Where-Object { $_ -match "Ubuntu" } | Select-Object -First 1
            Write-Log "SUCCESS: Ubuntu distribution already installed: $existingDistro"
        }
    } catch {
        Write-Log "Checking for existing Ubuntu installations..."
    }
    
    if (-not $ubuntuInstalled) {
        Write-Host "Installing Ubuntu 24.04 LTS via winget..." -ForegroundColor $Colors.Blue
        
        # Check if Ubuntu app is already installed
        $ubuntuApp = Get-AppxPackage -Name "*Ubuntu*" -ErrorAction SilentlyContinue
        if (-not $ubuntuApp) {
            Write-Host "Downloading and installing Ubuntu 24.04 LTS..." -ForegroundColor $Colors.Yellow
            $wingetProcess = Start-Process -FilePath "winget" -ArgumentList "install", "Canonical.Ubuntu.2404", "--accept-source-agreements", "--accept-package-agreements" -Wait -PassThru -NoNewWindow
            
            if ($wingetProcess.ExitCode -ne 0) {
                Write-Host "ERROR: Failed to install Ubuntu via winget" -ForegroundColor $Colors.Red
                Write-Host "Please install Ubuntu manually from Microsoft Store and run this setup again." -ForegroundColor $Colors.Yellow
                return
            }
            Write-Log "SUCCESS: Ubuntu 24.04 LTS downloaded via winget"
        } else {
            Write-Log "SUCCESS: Ubuntu app package already installed, will initialize for WSL"
        }
        
        Write-Host "Initializing Ubuntu for WSL..." -ForegroundColor $Colors.Blue
        
        # Initialize Ubuntu for WSL
        if (Get-Command ubuntu2404.exe -ErrorAction SilentlyContinue) {
            Write-Host "Running Ubuntu 24.04 initialization..." -ForegroundColor $Colors.Yellow
            ubuntu2404.exe install --root
            Write-Log "SUCCESS: Ubuntu 24.04 initialized"
        } elseif (Get-Command ubuntu.exe -ErrorAction SilentlyContinue) {
            Write-Host "Running Ubuntu initialization..." -ForegroundColor $Colors.Yellow
            ubuntu.exe install --root
            Write-Log "SUCCESS: Ubuntu initialized"
        } else {
            Write-Host "ERROR: Ubuntu executable not found. Please run Ubuntu from Start Menu once to initialize." -ForegroundColor $Colors.Red
            return
        }
        
        # Verify WSL registration
        Write-Host "Verifying Ubuntu registration with WSL..." -ForegroundColor $Colors.Yellow
        Start-Sleep -Seconds 5
        $finalCheck = wsl --list --verbose 2>$null
        if (-not ($finalCheck | Select-String "Ubuntu")) {
            Write-Host "ERROR: Ubuntu installation verification failed" -ForegroundColor $Colors.Red
            Write-Host "Available WSL distributions:" -ForegroundColor $Colors.Yellow
            wsl --list --verbose
            return
        }
        
        Write-Log "SUCCESS: Ubuntu installation and initialization complete"
    }
    
    # Create WSL config if custom path specified
    if ($WSLPath -ne "D:\WSL") {
        Write-Log "Creating custom WSL configuration..."
        $wslConfigPath = Join-Path $env:USERPROFILE ".wslconfig"
        $wslConfig = @"
[wsl2]
memory=16GB
processors=8
swap=4GB
localhostForwarding=true

[experimental]
sparseVhd=true
"@
        $wslConfig | Out-File -FilePath $wslConfigPath -Encoding UTF8
        Write-Log "SUCCESS: WSL configuration created"
    }
    
    Write-Log "SUCCESS: WSL2 setup complete"
}

# Initialize Ubuntu in WSL
function Initialize-Ubuntu {
    Write-Log "Configuring Ubuntu in WSL..."
    
    # Check if any Ubuntu distribution is installed - try known distribution names
    $ubuntuDistro = $null
    $possibleDistros = @("Ubuntu-24.04", "Ubuntu-22.04", "Ubuntu-20.04", "Ubuntu")
    
    foreach ($distro in $possibleDistros) {
        try {
            # Test if this distribution exists by trying to run a simple command
            $testResult = wsl --distribution $distro -- echo "test" 2>$null
            if ($testResult -eq "test") {
                $ubuntuDistro = $distro
                break
            }
        } catch {
            # Continue to next distribution
        }
    }
    
    if (-not $ubuntuDistro) {
        Write-Log "ERROR: No Ubuntu distribution found in WSL. Please run option 3 (WSL/Ubuntu setup only) first."
        Write-Host "Available distributions:" -ForegroundColor $Colors.Yellow
        try {
            wsl --list --verbose
        } catch {
            Write-Host "Could not list WSL distributions" -ForegroundColor $Colors.Red
        }
        return
    }
    
    Write-Log "SUCCESS: Found Ubuntu distribution: $ubuntuDistro"
    
    # Create Ubuntu setup script
    $tempScript = Join-Path $env:TEMP "ubuntu-setup.sh"
    $setupScript = @'
#!/bin/bash
echo "Setting up Ubuntu development environment..."

# Update system
sudo apt update
sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git zsh build-essential

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Set zsh as default shell
sudo chsh -s $(which zsh) $USER

echo "SUCCESS: Ubuntu setup complete!"
echo "Please restart your terminal and run: exec zsh"
'@
    
    $setupScript | Out-File -FilePath $tempScript -Encoding UTF8
    
    Write-Host "Running Ubuntu setup in WSL..." -ForegroundColor $Colors.Blue
    $tempScriptLinux = "/mnt/c/Users/$env:USERNAME/AppData/Local/Temp/ubuntu-setup.sh"
    
    try {
        # Use the specific Ubuntu distribution name
        wsl --distribution $ubuntuDistro -- bash -c "chmod +x '$tempScriptLinux' && '$tempScriptLinux'"
        Write-Log "SUCCESS: Ubuntu configuration completed using distribution: $ubuntuDistro"
    } catch {
        Write-Log "Failed to run setup script in Ubuntu distribution: $ubuntuDistro" -Level "WARN"
        # Try with default WSL
        try {
            wsl -- bash -c "chmod +x '$tempScriptLinux' && '$tempScriptLinux'"
            Write-Log "SUCCESS: Ubuntu configuration completed using default WSL"
        } catch {
            Write-Log "ERROR: Failed to configure Ubuntu in WSL: $($_.Exception.Message)" -Level "ERROR"
        }
    }
    
    # Clean up temp file
    Remove-Item $tempScript -ErrorAction SilentlyContinue
}

# Configure Git in WSL with proper credential helper
function Set-WSLGitConfiguration {
    Write-Log "Configuring Git in WSL..."
    
    # Check if WSL is available
    try {
        $wslTest = wsl --list --verbose 2>$null
        if (-not $wslTest) {
            Write-Log "WSL not available, skipping WSL Git configuration" -Level "WARN"
            return
        }
    } catch {
        Write-Log "WSL not available, skipping WSL Git configuration" -Level "WARN"
        return
    }
    
    # Get Git user details
    $gitName = Read-Host "Enter your Git name for WSL"
    $gitEmail = Read-Host "Enter your Git email for WSL"
    
    # Check if Git is already configured in WSL
    try {
        $wslGitName = wsl -- git config --global user.name 2>$null
        $wslGitEmail = wsl -- git config --global user.email 2>$null
        
        if ($wslGitName -or $wslGitEmail) {
            Write-Log "Existing Git configuration found in WSL:"
            if ($wslGitName) { Write-Log "  Current name: $wslGitName" }
            if ($wslGitEmail) { Write-Log "  Current email: $wslGitEmail" }
            
            $overwrite = Read-Host "Do you want to overwrite the existing WSL Git configuration? [y/N]"
            if ($overwrite -notmatch "^[Yy]$") {
                Write-Log "Keeping existing WSL Git configuration"
                return
            }
        }
    } catch {
        # WSL or Git not available, continue with setup
    }
    
    # Create WSL Git configuration script
    $wslGitScript = @"
#!/bin/bash
echo "Configuring Git in WSL..."

# Set up Git user
git config --global user.name '$gitName'
git config --global user.email '$gitEmail'

# Set up Windows Git Credential Manager for WSL
git config --global credential.helper '/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe'

# Set other useful Git defaults
git config --global init.defaultBranch main
git config --global pull.rebase false

echo "Git configuration completed in WSL"
"@
    
    # Write script to temp file
    $tempScript = Join-Path $env:TEMP "wsl-git-setup.sh"
    $wslGitScript | Out-File -FilePath $tempScript -Encoding UTF8
    
    # Run script in WSL
    $tempScriptLinux = "/mnt/c/Users/$env:USERNAME/AppData/Local/Temp/wsl-git-setup.sh"
    
    try {
        wsl -- bash -c "chmod +x '$tempScriptLinux' && '$tempScriptLinux'"
        Write-Log "SUCCESS: Git configured in WSL with Windows Credential Manager"
    } catch {
        Write-Log "ERROR: Failed to configure Git in WSL: $($_.Exception.Message)" -Level "ERROR"
    }
    
    # Clean up temp file
    Remove-Item $tempScript -ErrorAction SilentlyContinue
}

# Set Git configuration
function Set-GitConfiguration {
    Write-Log "Configuring Git..."
    
    # Generate .gitconfig from template
    $templatePath = Join-Path $SETUP_DIR "common\.gitconfig.template"
    $targetPath = Join-Path $env:USERPROFILE ".gitconfig"
    
    if (Test-Path $templatePath) {
        Write-Log "Generating .gitconfig from template..."
        
        # Check if .gitconfig already exists
        if (Test-Path $targetPath) {
            Write-Log "Existing .gitconfig found at $targetPath"
            Write-Host ""
            Write-Host "An existing Git configuration was found:" -ForegroundColor Yellow
            Write-Host "  Location: $targetPath" -ForegroundColor Yellow
            
            # Try to show current Git config
            try {
                $currentName = git config --global user.name 2>$null
                $currentEmail = git config --global user.email 2>$null
                if ($currentName) { Write-Host "  Current name: $currentName" -ForegroundColor Yellow }
                if ($currentEmail) { Write-Host "  Current email: $currentEmail" -ForegroundColor Yellow }
            } catch {
                # Git not available or no config set
            }
            
            Write-Host ""
            $overwrite = Read-Host "Do you want to overwrite the existing .gitconfig? [y/N]"
            if ($overwrite -notmatch "^[Yy]$") {
                Write-Log "Keeping existing .gitconfig, skipping generation"
                return
            }
            
            # Backup existing file
            $backupPath = "$targetPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Copy-Item $targetPath $backupPath
            Write-Log "Backed up existing .gitconfig to $backupPath"
        }
        
        # Get Git user details
        $gitName = Read-Host "Enter your Git name"
        $gitEmail = Read-Host "Enter your Git email"
        
        # Define Windows credential helper
        $credentialHelper = @"
[credential]
	helper = manager
"@
        
        # Read template and replace placeholders
        $content = Get-Content $templatePath -Raw
        $content = $content -replace "__GIT_NAME__", $gitName
        $content = $content -replace "__GIT_EMAIL__", $gitEmail
        $content = $content -replace "__CREDENTIAL_HELPER__", $credentialHelper
        
        # Write to user's home directory
        Set-Content -Path $targetPath -Value $content -Encoding UTF8
        Write-Log "SUCCESS: .gitconfig created at $targetPath with Windows credential manager"
    } else {
        Write-Log "ERROR: .gitconfig.template not found at $templatePath" -Level "ERROR"
    }
}

# Main function
function Main {
    Show-Welcome
    
    if (-not (Test-Administrator)) {
        Write-Host "Please right-click and 'Run as Administrator'" -ForegroundColor $Colors.Yellow
        exit 1
    }
    
    Write-Log "Starting Windows development machine setup..."
    Write-Log "Setup directory: $SETUP_DIR"
    
    # Load Windows-specific modules
    Import-WindowsModules
    
    # Check prerequisites
    $prereqResult = Test-Prerequisites
    if (-not $prereqResult) {
        Write-Host "ERROR: Prerequisites check failed" -ForegroundColor $Colors.Red
        exit 1
    }
    # Show setup options
    Write-Host "Windows Development Machine Setup Options:" -ForegroundColor $Colors.Yellow
    Write-Host "1) Full setup (recommended for new machines)"
    Write-Host "2) Windows packages only"
    Write-Host "3) WSL/Ubuntu setup only"
    Write-Host "4) Custom setup (choose components)"
    Write-Host "5) Exit"
    Write-Host ""
    
    $choice = Read-Host "Choose an option [1-5]"
    
    switch ($choice) {
        "1" {
            Write-Log "Full Windows development machine setup selected"
            Install-Chocolatey
            Install-WindowsPackages
            $rebootNeeded = Enable-WindowsFeatures
            Set-GitConfiguration
            
            # Setup Windows-specific configuration
            if (Get-Command Setup-Windows -ErrorAction SilentlyContinue) {
                Setup-Windows
            }
            
            if ($rebootNeeded -and -not $SkipReboot) {
                $reboot = Read-Host "Reboot required for WSL. Reboot now? [Y/n]"
                if ($reboot -notmatch "^[Nn]$") {
                    Write-Log "Rebooting system to complete WSL installation..."
                    Restart-Computer -Force
                }
            }
            
            # Install WSL after reboot (or if skipping reboot)
            Install-WSL
            
            # Configure Git in WSL if WSL is available
            Set-WSLGitConfiguration
            
            Write-Host "Ubuntu is now installed in WSL. Please open WSL and manually set up packages, dotfiles, and your Linux environment." -ForegroundColor $Colors.Yellow
        }
        "2" {
            Write-Log "Windows packages-only setup selected"
            Install-Chocolatey
            Install-WindowsPackages
            
            # Setup Windows-specific configuration
            if (Get-Command Setup-Windows -ErrorAction SilentlyContinue) {
                Setup-Windows
            }
            
            Set-GitConfiguration
        }
        "3" {
            Write-Log "WSL/Ubuntu setup selected"
            $rebootNeeded = Enable-WindowsFeatures
            
            if ($rebootNeeded -and -not $SkipReboot) {
                $reboot = Read-Host "Reboot required for WSL. Reboot now? [Y/n]"
                if ($reboot -notmatch "^[Nn]$") {
                    Write-Log "Rebooting system to complete WSL installation..."
                    Restart-Computer -Force
                    return
                }
            }
            
            Install-WSL
            
            # Configure Git in WSL
            Set-WSLGitConfiguration
            
            Write-Host "Ubuntu is now installed in WSL. Please open WSL and manually set up packages, dotfiles, and your Linux environment." -ForegroundColor $Colors.Yellow
        }
        "4" {
            Write-Host ""
            Write-Host "Custom Setup - Select components:" -ForegroundColor $Colors.Yellow
            
            $installChoco = Read-Host "Install Chocolatey and Windows packages? [Y/n]"
            $enableFeatures = Read-Host "Enable Windows features (WSL, Hyper-V)? [Y/n]"
            $setupWindows = Read-Host "Configure Windows environment? [Y/n]"
            $setupWSL = Read-Host "Setup WSL2 and Ubuntu? [Y/n]"
            $configGit = Read-Host "Configure Git? [Y/n]"
            
            if ($installChoco -notmatch "^[Nn]$") {
                Install-Chocolatey
                Install-WindowsPackages
            }
            
            if ($enableFeatures -notmatch "^[Nn]$") {
                $rebootNeeded = Enable-WindowsFeatures
            }
            
            if ($setupWindows -notmatch "^[Nn]$" -and (Get-Command Setup-Windows -ErrorAction SilentlyContinue)) {
                Setup-Windows
            }
            
            if ($configGit -notmatch "^[Nn]$") {
                Set-GitConfiguration
            }
            
            if ($setupWSL -notmatch "^[Nn]$") {
                Install-WSL
                
                # Configure Git in WSL
                Set-WSLGitConfiguration
                
                Write-Host "Ubuntu is now installed in WSL. Please open WSL and manually set up packages, dotfiles, and your Linux environment." -ForegroundColor $Colors.Yellow
            }
        }
        "5" {
            Write-Log "Setup cancelled by user"
            exit 0
        }
        default {
            Write-Host "Invalid option" -ForegroundColor $Colors.Red
            exit 1
        }
    }
    
    # Success message
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor $Colors.Green
    Write-Host "                    Setup Complete!                            " -ForegroundColor $Colors.Green
    Write-Host "================================================================" -ForegroundColor $Colors.Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor $Colors.Blue
    Write-Host "   1. Open Windows Terminal and run 'wsl' to enter Ubuntu"
    Write-Host "   2. Inside WSL, manually install packages and configure your environment"
    Write-Host "   3. Set up dotfiles, shell configuration, and development tools as needed"
    Write-Host "   4. Refer to the docs/ folder for Linux setup guidance"
    Write-Host ""
    Write-Host "Setup log saved to: $env:USERPROFILE\.dev-machine-setup.log" -ForegroundColor $Colors.Blue
    Write-Host "Documentation: README.md and QUICK_START.md" -ForegroundColor $Colors.Blue
    Write-Host ""
    
    Write-Log "SUCCESS: Windows development machine setup completed successfully!"
}

# Run main function
Main

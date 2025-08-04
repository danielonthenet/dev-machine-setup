# Windows Package Lists for Development Machine Setup
# PowerShell module for managing Windows application installations via Chocolatey and winget

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Function to check if a winget package is installed
function Test-WingetPackageInstalled {
    param([string]$PackageId)
    try {
        $result = winget list --id $PackageId -e 2>$null
        return ($result -and $result -match $PackageId)
    }
    catch {
        return $false
    }
}

# Function to check if a chocolatey package is installed
function Test-ChocoPackageInstalled {
    param([string]$PackageName)
    try {
        $result = choco list --local-only $PackageName --exact 2>$null
        return ($result -and $result -match $PackageName -and $result -notmatch "0 packages installed")
    }
    catch {
        return $false
    }
}

# =============================================================================
# WINGET PACKAGES (preferred when available)
# =============================================================================

# Essential packages via winget
$WINGET_ESSENTIAL = @(
    "7zip.7zip",
    "Google.Chrome", 
    "Microsoft.WindowsTerminal",
    "Microsoft.PowerShell",
    "Notepad++.Notepad++",
    "Joplin.Joplin"
)

# Development tools via winget
$WINGET_DEV = @(
    "Microsoft.VisualStudioCode",
    "OpenJS.NodeJS.LTS",
    "Python.Python.3.12",
    "GoLang.Go",
    "RedHat.Podman-Desktop",
    "Postman.Postman",
    "GitHub.GitHubDesktop",
    "PuTTY.PuTTY",
    "Microsoft.OpenSSH.Beta"
)

# Communication apps via winget
$WINGET_COMM = @(
    "SlackTechnologies.Slack",
    "Zoom.Zoom",
    "Microsoft.Teams"
)

# Media applications via winget
$WINGET_MEDIA = @(
    "VideoLAN.VLC",
    "Audacity.Audacity", 
    "GIMP.GIMP",
    "HandBrake.HandBrake",
    "OBSProject.OBSStudio",
    "DuongDieuPhap.ImageGlass",
    "th-ch.YouTubeMusic"
)

# Utility applications via winget
$WINGET_UTILITY = @(
    "Microsoft.Sysinternals.ProcessMonitor",
    "WinDirStat.WinDirStat",
    "Microsoft.PowerToys",
    "voidtools.Everything",
    "AutoHotkey.AutoHotkey",
    "Greenshot.Greenshot",
    "WiresharkFoundation.Wireshark"
)

# Cloud CLI tools via winget
$WINGET_CLOUD = @(
    "Amazon.AWSCLI",
    "Microsoft.AzureCLI",
    "Hashicorp.Terraform",
    "Kubernetes.kubectl",
    "Helm.Helm"
)

# =============================================================================
# CHOCOLATEY PACKAGES (fallback for packages not available on winget)
# =============================================================================

# Essential packages via chocolatey (fallbacks)
$CHOCO_ESSENTIAL = @(
    # Most essentials are available on winget now
)

# Development tools via chocolatey (fallbacks)
$CHOCO_DEV = @(
    "curl",
    "wget"
)

# Communication apps via chocolatey (fallbacks)  
$CHOCO_COMM = @(
    # Most comm apps are available on winget now
)

# Media applications via chocolatey (fallbacks)
$CHOCO_MEDIA = @(
    # Most media apps are available on winget now
)

# Utility applications via chocolatey (fallbacks)
$CHOCO_UTILITY = @(
    "advanced-ip-scanner"  # Not available on winget
)

# Cloud CLI tools via chocolatey (fallbacks)
$CHOCO_CLOUD = @(
    # Most cloud tools are available on winget now
)

# Modern CLI tools (via winget and chocolatey)
$CLI_TOOLS_WINGET = @{
    "bat" = "sharkdp.bat"
    "ripgrep" = "BurntSushi.ripgrep.MSVC"
    "fd" = "sharkdp.fd"
    "fzf" = "junegunn.fzf"
    "jq" = "jqlang.jq"
}

$CLI_TOOLS_CHOCO = @(
    "yq",
    "httpie"
)

# Function to install essential packages
function Install-EssentialPackages {
    Write-Host "Installing essential packages..." -ForegroundColor Cyan
    
    # Install Git for Windows first (includes Git Credential Manager)
    Write-Host "Installing Git for Windows with Credential Manager..." -ForegroundColor Yellow
    try {
        if (Test-WingetPackageInstalled "Git.Git") {
            Write-Host "Git for Windows is already installed" -ForegroundColor Yellow
        } else {
            winget install --id=Git.Git -e --accept-source-agreements --accept-package-agreements
            if (Test-WingetPackageInstalled "Git.Git") {
                Write-Host "SUCCESS: Git for Windows installed successfully" -ForegroundColor Green
                
                # Verify Git Credential Manager is included
                Start-Sleep -Seconds 2  # Allow time for PATH refresh
                if (Get-Command git-credential-manager -ErrorAction SilentlyContinue) {
                    Write-Host "SUCCESS: Git Credential Manager is available" -ForegroundColor Green
                } else {
                    Write-Host "INFO: Git Credential Manager may need PATH refresh" -ForegroundColor Yellow
                }
            } else {
                throw "Git installation validation failed"
            }
        }
    }
    catch {
        Write-Host "ERROR: Failed to install Git for Windows" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    
    # Install winget essential packages
    foreach ($package in $WINGET_ESSENTIAL) {
        if (Test-WingetPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via winget..." -ForegroundColor Yellow
            try {
                winget install --id=$package -e --accept-source-agreements --accept-package-agreements
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
    
    # Install chocolatey essential packages (fallbacks)
    foreach ($package in $CHOCO_ESSENTIAL) {
        if (Test-ChocoPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via chocolatey..." -ForegroundColor Yellow
            try {
                choco install $package -y --no-progress --ignore-checksums
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
}

# Function to install development packages
function Install-DevPackages {
    Write-Host "Installing development packages..." -ForegroundColor Cyan
    
    # Install winget dev packages
    foreach ($package in $WINGET_DEV) {
        if (Test-WingetPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via winget..." -ForegroundColor Yellow
            try {
                winget install --id=$package -e --accept-source-agreements --accept-package-agreements
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
    
    # Install chocolatey dev packages (fallbacks)
    foreach ($package in $CHOCO_DEV) {
        if (Test-ChocoPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via chocolatey..." -ForegroundColor Yellow
            try {
                choco install $package -y --no-progress --ignore-checksums
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
}

# Function to install communication packages  
function Install-CommPackages {
    Write-Host "Installing communication packages..." -ForegroundColor Cyan
    
    # Install winget comm packages
    foreach ($package in $WINGET_COMM) {
        if (Test-WingetPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via winget..." -ForegroundColor Yellow
            try {
                winget install --id=$package -e --accept-source-agreements --accept-package-agreements
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
    
    # Install chocolatey comm packages (fallbacks)
    foreach ($package in $CHOCO_COMM) {
        if (Test-ChocoPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via chocolatey..." -ForegroundColor Yellow
            try {
                choco install $package -y --no-progress --ignore-checksums
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
}

# Function to install media packages
function Install-MediaPackages {
    Write-Host "Installing media packages..." -ForegroundColor Cyan
    
    # Install winget media packages
    foreach ($package in $WINGET_MEDIA) {
        if (Test-WingetPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via winget..." -ForegroundColor Yellow
            try {
                winget install --id=$package -e --accept-source-agreements --accept-package-agreements
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
    
    # Install chocolatey media packages (fallbacks)
    foreach ($package in $CHOCO_MEDIA) {
        if (Test-ChocoPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via chocolatey..." -ForegroundColor Yellow
            try {
                choco install $package -y --no-progress --ignore-checksums
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
}

# Function to install utility packages
function Install-UtilityPackages {
    Write-Host "Installing utility packages..." -ForegroundColor Cyan
    
    # Install winget utility packages
    foreach ($package in $WINGET_UTILITY) {
        if (Test-WingetPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via winget..." -ForegroundColor Yellow
            try {
                winget install --id=$package -e --accept-source-agreements --accept-package-agreements
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
    
    # Install chocolatey utility packages (fallbacks)
    foreach ($package in $CHOCO_UTILITY) {
        if (Test-ChocoPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via chocolatey..." -ForegroundColor Yellow
            try {
                choco install $package -y --no-progress --ignore-checksums
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
}

# Function to install cloud packages
function Install-CloudPackages {
    Write-Host "Installing cloud CLI tools..." -ForegroundColor Cyan
    
    # Install winget cloud packages
    foreach ($package in $WINGET_CLOUD) {
        if (Test-WingetPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via winget..." -ForegroundColor Yellow
            try {
                winget install --id=$package -e --accept-source-agreements --accept-package-agreements
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
    
    # Install chocolatey cloud packages (fallbacks)
    foreach ($package in $CHOCO_CLOUD) {
        if (Test-ChocoPackageInstalled $package) {
            Write-Host "$package is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $package via chocolatey..." -ForegroundColor Yellow
            try {
                choco install $package -y --no-progress --ignore-checksums
                Write-Host "SUCCESS: $package installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $package" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
}

# Function to install modern CLI tools
function Install-CLITools {
    Write-Host "Installing modern CLI tools..." -ForegroundColor Cyan
    
    # Install CLI tools via winget
    foreach ($tool in $CLI_TOOLS_WINGET.GetEnumerator()) {
        if (Test-WingetPackageInstalled $tool.Value) {
            Write-Host "$($tool.Key) is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $($tool.Key) via winget..." -ForegroundColor Yellow
            try {
                winget install --id=$($tool.Value) -e --accept-source-agreements --accept-package-agreements
                Write-Host "SUCCESS: $($tool.Key) installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $($tool.Key)" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
    
    # Install remaining CLI tools via chocolatey
    foreach ($tool in $CLI_TOOLS_CHOCO) {
        if (Test-ChocoPackageInstalled $tool) {
            Write-Host "$tool is already installed" -ForegroundColor Yellow
        } else {
            Write-Host "Installing $tool via chocolatey..." -ForegroundColor Yellow
            try {
                choco install $tool -y --no-progress --ignore-checksums
                Write-Host "SUCCESS: $tool installed successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "ERROR: Failed to install $tool" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
        }
    }
}

# Function for interactive package selection
function Install-InteractivePackages {
    Write-Host "[INFO] Install-InteractivePackages function loaded and called." -ForegroundColor Green
    Write-Host ""
    Write-Host "Package Installation Options:" -ForegroundColor Yellow
    Write-Host "1) Essential only (terminal, browser, editor)"
    Write-Host "2) Development setup (includes dev tools)" 
    Write-Host "3) Full productivity (includes communication apps)"
    Write-Host "4) Everything (includes media and utilities)"
    Write-Host "5) Custom selection"
    Write-Host ""
    
    $choice = Read-Host "Choose installation type [1-5]"
    
    switch ($choice) {
        "1" {
            Install-EssentialPackages
        }
        "2" {
            Install-EssentialPackages
            Install-DevPackages
            Install-CLITools
        }
        "3" {
            Install-EssentialPackages
            Install-DevPackages
            Install-CommPackages
            Install-CLITools
        }
        "4" {
            Install-EssentialPackages
            Install-DevPackages
            Install-CommPackages
            Install-MediaPackages
            Install-UtilityPackages
            Install-CloudPackages
            Install-CLITools
        }
        "5" {
            Write-Host "Custom package selection:" -ForegroundColor Yellow
            $installEssential = Read-Host "Install essential packages? (Y/n)"
            if ($installEssential -ne "n") { Install-EssentialPackages }
            
            $installDev = Read-Host "Install development packages? (Y/n)"
            if ($installDev -ne "n") { Install-DevPackages }
            
            $installComm = Read-Host "Install communication packages? (y/N)"
            if ($installComm -eq "y") { Install-CommPackages }
            
            $installMedia = Read-Host "Install media packages? (y/N)"
            if ($installMedia -eq "y") { Install-MediaPackages }
            
            $installUtility = Read-Host "Install utility packages? (y/N)"
            if ($installUtility -eq "y") { Install-UtilityPackages }
            
            $installCloud = Read-Host "Install cloud CLI tools? (y/N)"
            if ($installCloud -eq "y") { Install-CloudPackages }
            
            $installCLI = Read-Host "Install modern CLI tools? (Y/n)"
            if ($installCLI -ne "n") { Install-CLITools }
        }
        default {
            Write-Host "Installing essentials only..." -ForegroundColor Yellow
            Install-EssentialPackages
        }
    }
}

# Export functions for use in main setup script

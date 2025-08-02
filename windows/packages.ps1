# Windows Package Lists for Development Machine Setup
# PowerShell module for managing Windows application installations via Chocolatey and winget

# Essential packages (always install)
$ESSENTIAL_PACKAGES = @(
    "7zip", 
    "googlechrome",
    "microsoft-windows-terminal",
    "powershell-core",
    "notepadplusplus"
)

# Development tools and environments
$DEV_PACKAGES = @(
    "vscode",
    "nodejs-lts",
    "python",
    "golang",
    "podman-desktop",
    "postman",
    "github-desktop",
    "sourcetree",
    "putty",
    "openssh",
    "curl",
    "wget"
)

# Communication and productivity applications
$COMM_PACKAGES = @(
    "slack",
    "zoom",
    "microsoft-teams"
)

# Media and utility applications  
$MEDIA_PACKAGES = @(
    "vlc",
    "audacity",
    "gimp",
    "handbrake",
    "obs-studio",
    "imageglass"
)

# Developer utilities
$UTILITY_PACKAGES = @(
    "sysinternals",
    "windirstat",
    "powertoys",
    "everything",
    "autohotkey",
    "greenshot",
    "wireshark",
    "advanced-ip-scanner"
)

# Cloud CLI tools
$CLOUD_PACKAGES = @(
    "awscli",
    "azure-cli", 
    "terraform",
    "kubernetes-cli",
    "helm"
)

# Modern CLI tools (via scoop or direct download)
$CLI_TOOLS = @(
    "bat",
    "ripgrep", 
    "fd",
    "fzf",
    "jq",
    "yq",
    "httpie"
)

# Function to install essential packages
function Install-EssentialPackages {
    Write-Host "Installing essential packages..." -ForegroundColor Cyan
    
    # Install Git for Windows (includes Git Credential Manager)
    Write-Host "Installing Git for Windows with Credential Manager..." -ForegroundColor Yellow
    try {
        # Check if already installed
        $gitInstalled = winget list --id Git.Git -e 2>$null
        if ($gitInstalled -and $gitInstalled -match "Git.Git") {
            Write-Host "Git for Windows is already installed" -ForegroundColor Yellow
        } else {
            winget install --id=Git.Git -e
            # Validate installation
            $gitValidation = winget list --id Git.Git -e 2>$null
            if ($gitValidation -and $gitValidation -match "Git.Git") {
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
    
    foreach ($package in $ESSENTIAL_PACKAGES) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
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

# Function to install development packages
function Install-DevPackages {
    Write-Host "Installing development packages..." -ForegroundColor Cyan
    foreach ($package in $DEV_PACKAGES) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
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

# Function to install communication packages  
function Install-CommPackages {
    Write-Host "Installing communication packages..." -ForegroundColor Cyan
    foreach ($package in $COMM_PACKAGES) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
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

# Function to install media packages
function Install-MediaPackages {
    Write-Host "Installing media packages..." -ForegroundColor Cyan
    foreach ($package in $MEDIA_PACKAGES) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
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

# Function to install utility packages
function Install-UtilityPackages {
    Write-Host "Installing utility packages..." -ForegroundColor Cyan
    foreach ($package in $UTILITY_PACKAGES) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
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

# Function to install cloud packages
function Install-CloudPackages {
    Write-Host "Installing cloud CLI tools..." -ForegroundColor Cyan
    foreach ($package in $CLOUD_PACKAGES) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
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

# Function to install modern CLI tools via Scoop
function Install-CLITools {
    Write-Host "Installing modern CLI tools via Scoop..." -ForegroundColor Cyan
    
    # Install Scoop if not present
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop package manager..." -ForegroundColor Yellow
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        
        # Add buckets
        scoop bucket add extras
        scoop bucket add main
    }
    
    foreach ($tool in $CLI_TOOLS) {
        Write-Host "Installing $tool..." -ForegroundColor Yellow
        try {
            scoop install $tool
            Write-Host "SUCCESS: $tool installed successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "ERROR: Failed to install $tool" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
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

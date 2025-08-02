# Windows Development Machine Setup - Test Mode
# This runs the setup in simulation mode to show what would happen

param(
    [switch]$TestMode
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
}

# Welcome message
function Show-Welcome {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $Colors.Blue
    Write-Host "║               Windows Dev Machine Setup - TEST MODE         ║" -ForegroundColor $Colors.Blue
    Write-Host "║                    Simulation Only                          ║" -ForegroundColor $Colors.Blue
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $Colors.Blue
    Write-Host ""
}

# Simulate package installation
function Simulate-PackageInstall {
    param([string]$PackageName)
    Write-Host "[TEST] Would install: $PackageName" -ForegroundColor $Colors.Yellow
    Start-Sleep -Milliseconds 100  # Simulate some processing time
}

# Override choco command for test mode
function choco {
    param(
        [string]$Command,
        [string]$Package,
        [string]$Options
    )
    if ($Command -eq "install") {
        Simulate-PackageInstall $Package
    } else {
        Write-Host "[TEST] Would run: choco $Command $Package $Options" -ForegroundColor $Colors.Yellow
    }
}

# Override scoop command for test mode
function scoop {
    param([string[]]$Arguments)
    Write-Host "[TEST] Would run: scoop $($Arguments -join ' ')" -ForegroundColor $Colors.Yellow
}

# Override Windows feature commands
function Enable-WindowsOptionalFeature {
    param(
        [string]$Online,
        [string]$FeatureName,
        [string]$NoRestart
    )
    Write-Host "[TEST] Would enable Windows feature: $FeatureName" -ForegroundColor $Colors.Yellow
    return @{ RestartNeeded = $false }
}

function Set-ItemProperty {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value
    )
    Write-Host "[TEST] Would set registry: $Path\$Name = $Value" -ForegroundColor $Colors.Yellow
}

function New-Item {
    param(
        [string]$Path,
        [string]$ItemType,
        [switch]$Force
    )
    Write-Host "[TEST] Would create ${ItemType}: $Path" -ForegroundColor $Colors.Yellow
}

Show-Welcome

Write-Log "🧪 Starting Windows development machine setup in TEST MODE..."
Write-Log "📁 Setup directory: $SETUP_DIR"

# Load Windows-specific modules (test mode)
Write-Log "📦 Loading Windows-specific modules..."

try {
    $packagesPath = Join-Path $SETUP_DIR "windows\packages.ps1"
    if (Test-Path $packagesPath) {
        # Load packages module without Export-ModuleMember
        $packagesContent = Get-Content $packagesPath -Raw
        $packagesContent = $packagesContent -replace "Export-ModuleMember.*", ""
        Invoke-Expression $packagesContent
        Write-Log "✅ Windows packages module loaded"
    }
    
    $setupPath = Join-Path $SETUP_DIR "windows\setup_windows.ps1"
    if (Test-Path $setupPath) {
        # Load setup module without Export-ModuleMember
        $setupContent = Get-Content $setupPath -Raw
        $setupContent = $setupContent -replace "Export-ModuleMember.*", ""
        Invoke-Expression $setupContent
        Write-Log "✅ Windows setup module loaded"
    }
} catch {
    Write-Log "❌ Failed to load Windows modules: $($_.Exception.Message)" -Level "ERROR"
    exit 1
}

# Show what would be done
Write-Host ""
Write-Host "🚀 TEST MODE: Here's what the setup would do:" -ForegroundColor $Colors.Green
Write-Host ""

Write-Host "1. CHOCOLATEY INSTALLATION:" -ForegroundColor $Colors.Blue
Write-Host "   [TEST] Would install Chocolatey package manager" -ForegroundColor $Colors.Yellow

Write-Host ""
Write-Host "2. ESSENTIAL PACKAGES:" -ForegroundColor $Colors.Blue
foreach ($package in $ESSENTIAL_PACKAGES) {
    Write-Host "   [TEST] Would install: $package" -ForegroundColor $Colors.Yellow
}

Write-Host ""
Write-Host "3. DEVELOPMENT PACKAGES:" -ForegroundColor $Colors.Blue
foreach ($package in $DEV_PACKAGES) {
    Write-Host "   [TEST] Would install: $package" -ForegroundColor $Colors.Yellow
}

Write-Host ""
Write-Host "4. MODERN CLI TOOLS (via Scoop):" -ForegroundColor $Colors.Blue
foreach ($tool in $CLI_TOOLS) {
    Write-Host "   [TEST] Would install: $tool" -ForegroundColor $Colors.Yellow
}

Write-Host ""
Write-Host "5. WINDOWS FEATURES:" -ForegroundColor $Colors.Blue
Write-Host "   [TEST] Would enable: Microsoft-Windows-Subsystem-Linux" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would enable: VirtualMachinePlatform" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would enable: Microsoft-Hyper-V-All (if supported)" -ForegroundColor $Colors.Yellow

Write-Host ""
Write-Host "6. WSL2 SETUP:" -ForegroundColor $Colors.Blue
Write-Host "   [TEST] Would install WSL2" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would install Ubuntu distribution" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would set WSL2 as default version" -ForegroundColor $Colors.Yellow

Write-Host ""
Write-Host "7. WINDOWS CONFIGURATION:" -ForegroundColor $Colors.Blue
Write-Host "   [TEST] Would configure PowerShell profile with aliases" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would set up Windows Terminal settings" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would modify registry settings (show file extensions, etc.)" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would create development directories" -ForegroundColor $Colors.Yellow

Write-Host ""
Write-Host "8. ENVIRONMENT VARIABLES:" -ForegroundColor $Colors.Blue
Write-Host "   [TEST] Would set EDITOR=code" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would set BROWSER=chrome" -ForegroundColor $Colors.Yellow
Write-Host "   [TEST] Would add development paths to PATH" -ForegroundColor $Colors.Yellow

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $Colors.Green
Write-Host "║                     🎉 TEST COMPLETE! 🎉                    ║" -ForegroundColor $Colors.Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $Colors.Green
Write-Host ""
Write-Host "📋 To run the ACTUAL setup:" -ForegroundColor $Colors.Blue
Write-Host "   1. Right-click Start Menu → 'Windows PowerShell (Admin)'" -ForegroundColor $Colors.White
Write-Host "   2. Navigate to: cd '$SETUP_DIR'" -ForegroundColor $Colors.White
Write-Host "   3. Run: .\setup_windows.ps1" -ForegroundColor $Colors.White
Write-Host ""
Write-Host "⚠️ IMPORTANT:" -ForegroundColor $Colors.Yellow
Write-Host "   • Administrator privileges are REQUIRED" -ForegroundColor $Colors.White
Write-Host "   • A system reboot may be needed for WSL2" -ForegroundColor $Colors.White
Write-Host "   • The process may take 20-45 minutes" -ForegroundColor $Colors.White
Write-Host "   • Ensure you have a stable internet connection" -ForegroundColor $Colors.White
Write-Host ""
Write-Host "📜 All actions will be logged to: $env:USERPROFILE\.dev-machine-setup.log" -ForegroundColor $Colors.Blue
Write-Host ""

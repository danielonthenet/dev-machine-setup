# Test script for Windows setup validation
# This script tests the Windows setup without actually installing anything

param(
    [switch]$DryRun
)

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green" 
    Yellow = "Yellow"
    Blue = "Cyan"
    Purple = "Magenta"
    White = "White"
}

Write-Host "🧪 Testing Windows Development Machine Setup" -ForegroundColor $Colors.Blue
Write-Host "=============================================" -ForegroundColor $Colors.Blue
Write-Host ""

# Get script directory
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Test 1: Check if main script can be loaded
Write-Host "Test 1: Loading main setup script..." -ForegroundColor $Colors.Yellow
try {
    $setupPath = Join-Path $SETUP_DIR "setup_windows.ps1"
    if (Test-Path $setupPath) {
        # Test syntax without executing
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $setupPath -Raw), [ref]$null)
        Write-Host "✅ Main setup script syntax OK" -ForegroundColor $Colors.Green
    } else {
        Write-Host "❌ Main setup script not found" -ForegroundColor $Colors.Red
    }
} catch {
    Write-Host "❌ Main setup script has syntax errors: $($_.Exception.Message)" -ForegroundColor $Colors.Red
}

# Test 2: Check Windows modules
Write-Host "`nTest 2: Checking Windows modules..." -ForegroundColor $Colors.Yellow
$windowsModules = @("packages.ps1", "setup_windows.ps1", "aliases.ps1")

foreach ($module in $windowsModules) {
    $modulePath = Join-Path $SETUP_DIR "windows\$module"
    try {
        if (Test-Path $modulePath) {
            $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $modulePath -Raw), [ref]$null)
            Write-Host "✅ $module syntax OK" -ForegroundColor $Colors.Green
        } else {
            Write-Host "❌ $module not found" -ForegroundColor $Colors.Red
        }
    } catch {
        Write-Host "❌ $module has syntax errors: $($_.Exception.Message)" -ForegroundColor $Colors.Red
    }
}

# Test 3: Check if we can load Windows modules
Write-Host "`nTest 3: Testing module loading..." -ForegroundColor $Colors.Yellow
try {
    $packagesPath = Join-Path $SETUP_DIR "windows\packages.ps1"
    if (Test-Path $packagesPath) {
        . $packagesPath
        Write-Host "✅ Windows packages module loaded successfully" -ForegroundColor $Colors.Green
        
        # Test if key functions exist
        $functions = @("Install-EssentialPackages", "Install-DevPackages", "Install-InteractivePackages")
        foreach ($func in $functions) {
            if (Get-Command $func -ErrorAction SilentlyContinue) {
                Write-Host "✅ Function $func available" -ForegroundColor $Colors.Green
            } else {
                Write-Host "❌ Function $func not found" -ForegroundColor $Colors.Red
            }
        }
    }
} catch {
    Write-Host "❌ Failed to load Windows packages module: $($_.Exception.Message)" -ForegroundColor $Colors.Red
}

# Test 4: Check prerequisites (without admin check)
Write-Host "`nTest 4: Checking system compatibility..." -ForegroundColor $Colors.Yellow

# Check Windows version
$osVersion = [System.Environment]::OSVersion.Version
Write-Host "Windows Version: $($osVersion.Major).$($osVersion.Minor)" -ForegroundColor $Colors.Blue

if ($osVersion.Major -ge 10) {
    Write-Host "✅ Windows version compatible" -ForegroundColor $Colors.Green
} else {
    Write-Host "❌ Windows 10 or later required" -ForegroundColor $Colors.Red
}

# Check available disk space
$systemDrive = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
$freeSpaceGB = [math]::Round($systemDrive.FreeSpace / 1GB, 2)
Write-Host "Available disk space: ${freeSpaceGB}GB" -ForegroundColor $Colors.Blue

if ($freeSpaceGB -gt 10) {
    Write-Host "✅ Sufficient disk space available" -ForegroundColor $Colors.Green
} else {
    Write-Host "⚠️ Low disk space (less than 10GB)" -ForegroundColor $Colors.Yellow
}

# Test 5: Check if common tools are available
Write-Host "`nTest 5: Checking for existing tools..." -ForegroundColor $Colors.Yellow

$tools = @(
    @{Name="Git"; Command="git"},
    @{Name="Chocolatey"; Command="choco"},
    @{Name="PowerShell Core"; Command="pwsh"},
    @{Name="Windows Terminal"; Command="wt"},
    @{Name="VS Code"; Command="code"}
)

foreach ($tool in $tools) {
    if (Get-Command $tool.Command -ErrorAction SilentlyContinue) {
        Write-Host "✅ $($tool.Name) found" -ForegroundColor $Colors.Green
    } else {
        Write-Host "⚪ $($tool.Name) not found (will be installed)" -ForegroundColor $Colors.Yellow
    }
}

# Test 6: Check WSL status
Write-Host "`nTest 6: Checking WSL status..." -ForegroundColor $Colors.Yellow
try {
    $wslVersion = wsl --status 2>$null
    if ($wslVersion) {
        Write-Host "✅ WSL is installed" -ForegroundColor $Colors.Green
    }
} catch {
    Write-Host "⚪ WSL not installed (will be configured)" -ForegroundColor $Colors.Yellow
}

# Summary
Write-Host "`n🎯 Test Summary" -ForegroundColor $Colors.Blue
Write-Host "===============" -ForegroundColor $Colors.Blue
Write-Host "The Windows development machine setup appears to be ready for testing." -ForegroundColor $Colors.Green
Write-Host ""
Write-Host "💡 To run the actual setup:" -ForegroundColor $Colors.Yellow
Write-Host "   1. Open PowerShell as Administrator" -ForegroundColor $Colors.White
Write-Host "   2. Run: .\setup_windows.ps1" -ForegroundColor $Colors.White
Write-Host ""
Write-Host "⚠️ Remember: Administrator privileges are required for:" -ForegroundColor $Colors.Yellow
Write-Host "   - Installing Chocolatey packages" -ForegroundColor $Colors.White
Write-Host "   - Enabling Windows features (WSL, Hyper-V)" -ForegroundColor $Colors.White
Write-Host "   - Modifying system registry settings" -ForegroundColor $Colors.White
Write-Host ""

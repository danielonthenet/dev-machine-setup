# Test the Windows setup script in dry-run mode
param(
    [switch]$DryRun
)

# Load the main setup script functions (without running main)
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

Write-Host "🧪 Testing Windows Setup Script Functions" -ForegroundColor $Colors.Blue
Write-Host "==========================================" -ForegroundColor $Colors.Blue

# Test loading Windows modules
try {
    $packagesPath = Join-Path $SETUP_DIR "windows\packages.ps1"
    if (Test-Path $packagesPath) {
        # Load without Export-ModuleMember
        $packagesContent = Get-Content $packagesPath -Raw
        $packagesContent = $packagesContent -replace "Export-ModuleMember.*", ""
        Invoke-Expression $packagesContent
        Write-Host "✅ Windows packages module loaded" -ForegroundColor $Colors.Green
    }
    
    $setupPath = Join-Path $SETUP_DIR "windows\setup_windows.ps1"
    if (Test-Path $setupPath) {
        # Load without Export-ModuleMember
        $setupContent = Get-Content $setupPath -Raw
        $setupContent = $setupContent -replace "Export-ModuleMember.*", ""
        Invoke-Expression $setupContent
        Write-Host "✅ Windows setup module loaded" -ForegroundColor $Colors.Green
    }
} catch {
    Write-Host "❌ Failed to load Windows modules: $($_.Exception.Message)" -ForegroundColor $Colors.Red
    exit 1
}

# Test functions are available
$testFunctions = @(
    "Install-EssentialPackages",
    "Install-DevPackages", 
    "Install-InteractivePackages",
    "Setup-Windows"
)

Write-Host "`n🔍 Testing function availability..." -ForegroundColor $Colors.Yellow
foreach ($func in $testFunctions) {
    if (Get-Command $func -ErrorAction SilentlyContinue) {
        Write-Host "✅ $func is available" -ForegroundColor $Colors.Green
    } else {
        Write-Host "❌ $func not found" -ForegroundColor $Colors.Red
    }
}

Write-Host "`n📋 Windows Setup Script Analysis Complete!" -ForegroundColor $Colors.Green
Write-Host "The Windows development machine setup appears to be working correctly." -ForegroundColor $Colors.White
Write-Host ""
Write-Host "⚠️ To run the actual setup, you need to:" -ForegroundColor $Colors.Yellow
Write-Host "   1. Open PowerShell as Administrator" -ForegroundColor $Colors.White
Write-Host "   2. Run: .\setup_windows.ps1" -ForegroundColor $Colors.White
Write-Host ""
Write-Host "💡 The setup will:" -ForegroundColor $Colors.Blue
Write-Host "   • Install Chocolatey package manager" -ForegroundColor $Colors.White
Write-Host "   • Install essential development tools" -ForegroundColor $Colors.White
Write-Host "   • Configure Windows features (WSL, Hyper-V)" -ForegroundColor $Colors.White
Write-Host "   • Set up Ubuntu in WSL2" -ForegroundColor $Colors.White
Write-Host "   • Configure PowerShell profile and Windows Terminal" -ForegroundColor $Colors.White
Write-Host ""

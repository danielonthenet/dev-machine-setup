# Windows-specific aliases
# PowerShell aliases for development workflow

# Navigation aliases
Set-Alias -Name .. -Value Set-LocationParent
Set-Alias -Name ... -Value Set-LocationGrandParent
Set-Alias -Name .... -Value Set-LocationGreatGrandParent

function Set-LocationParent { Set-Location .. }
function Set-LocationGrandParent { Set-Location ..\.. }
function Set-LocationGreatGrandParent { Set-Location ..\..\.. }

# File operations
Set-Alias -Name ll -Value Get-ChildItemLong
Set-Alias -Name la -Value Get-ChildItemAll
Set-Alias -Name l -Value Get-ChildItem

function Get-ChildItemLong { Get-ChildItem -Force | Format-Table -AutoSize }
function Get-ChildItemAll { Get-ChildItem -Force -Hidden | Format-Table -AutoSize }

# System aliases
Set-Alias -Name which -Value Get-Command
Set-Alias -Name grep -Value Select-String
Set-Alias -Name ps -Value Get-Process
Set-Alias -Name kill -Value Stop-Process
Set-Alias -Name open -Value Invoke-Item

# Podman aliases (if podman is available)
if (Get-Command podman -ErrorAction SilentlyContinue) {
    function d { podman @args }
    function dc { podman-compose @args }
    function dps { podman ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" }
    function dclean { podman system prune -af }
    
    # Docker compatibility aliases
    function docker { podman @args }
    function docker-compose { podman-compose @args }
}

# Kubernetes aliases (if kubectl is available)
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    function k { kubectl @args }
    function kgp { kubectl get pods @args }
    function kgs { kubectl get services @args }
    function kgn { kubectl get nodes @args }
    function kgd { kubectl get deployments @args }
}

# Network and system utilities
function myip { (Invoke-WebRequest -Uri "https://api.ipify.org").Content }
function ports { Get-NetTCPConnection | Where-Object State -eq "Listen" | Sort-Object LocalPort }
function processes { Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 }
function sysinfo { Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory, CsProcessors }

# Development shortcuts
function edit { param([string]$file) if (Get-Command code -ErrorAction SilentlyContinue) { code $file } else { notepad $file } }
function reload { . $PROFILE }
function edit-profile { if (Get-Command code -ErrorAction SilentlyContinue) { code $PROFILE } else { notepad $PROFILE } }

# Modern CLI tool aliases (if available via Scoop)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat @args }
}

if (Get-Command exa -ErrorAction SilentlyContinue) {
    function ls { exa --icons @args }
    function ll { exa -la --icons @args }
    function tree { exa --tree @args }
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    function grep { rg @args }
}

if (Get-Command fd -ErrorAction SilentlyContinue) {
    function find { fd @args }
}

# Windows-specific system commands
function flush { ipconfig /flushdns }
function update { 
    Write-Host "Updating Chocolatey packages..." -ForegroundColor Yellow
    choco upgrade all -y
    
    Write-Host "Updating Scoop packages..." -ForegroundColor Yellow
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        scoop update *
    }
    
    Write-Host "Checking Windows Updates..." -ForegroundColor Yellow
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false
}

# File explorer shortcuts
function explorer { param([string]$path = ".") explorer.exe $path }
function code-here { code . }

# Package management shortcuts
function choco-search { param([string]$package) choco search $package }
function choco-install { param([string]$package) choco install $package -y }
function scoop-search { param([string]$package) scoop search $package }
function scoop-install { param([string]$package) scoop install $package }

Write-Host "✅ Windows-specific aliases loaded" -ForegroundColor Green

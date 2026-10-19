# Kiwii Installer Script (Install.ps1)
# Installs Kiwii module into PowerShell modules directory and configures $PROFILE

[CmdletBinding()]
param(
    [switch]$NoProfileUpdate,
    [switch]$Force,
    [string]$CustomModulePath
)

$ErrorActionPreference = 'Stop'

function Show-InstallHeader {
    Write-Host ""
    Write-Host "  _  ___          _ _ " -ForegroundColor Green -NoNewline
    Write-Host "  "
    Write-Host " | |/ (_)        (_)(_)" -ForegroundColor Green -NoNewline
    Write-Host "  [BETA]" -ForegroundColor Yellow
    Write-Host " | ' / _ _  _  _  _ _ " -ForegroundColor Green -NoNewline
    Write-Host "   v0.1.0-beta" -ForegroundColor DarkYellow
    Write-Host " |  < | | || || || | |" -ForegroundColor Green -NoNewline
    Write-Host "   PowerShell Customization Toolkit Installer" -ForegroundColor Cyan
    Write-Host " |_|\_|_|\_,_|\_,_|_|_|" -ForegroundColor Green
    Write-Host ""
}

Show-InstallHeader

# Determine module destination directory
if ($CustomModulePath) {
    $targetDir = $CustomModulePath
}
else {
    # Default user module paths:
    # Linux/macOS: ~/.local/share/powershell/Modules
    # Windows: $HOME\Documents\PowerShell\Modules or $HOME\Documents\WindowsPowerShell\Modules
    if ($IsWindows) {
        $targetDir = Join-Path $HOME "Documents\PowerShell\Modules\Kiwii"
    }
    else {
        $targetDir = Join-Path $HOME ".local/share/powershell/Modules/Kiwii"
    }
}

Write-Host "Installing Kiwii module to: " -NoNewline
Write-Host $targetDir -ForegroundColor Cyan

# Source path
$scriptRoot = $PSScriptRoot
if (-not $scriptRoot) {
    $scriptRoot = (Get-Location).Path
}

$sourceDir = Join-Path $scriptRoot "src/Kiwii"
if (-not (Test-Path $sourceDir)) {
    # Fallback if executing directly from src directory
    if (Test-Path (Join-Path $scriptRoot "Kiwii.psd1")) {
        $sourceDir = $scriptRoot
    }
    else {
        Write-Error "Could not find Kiwii module source directory at $sourceDir"
        exit 1
    }
}

# Create module directory
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# Copy files
Write-Host "Copying Kiwii module files..." -ForegroundColor Yellow
Copy-Item -Path (Join-Path $sourceDir "*") -Destination $targetDir -Recurse -Force

Write-Host "✓ Kiwii module successfully installed!" -ForegroundColor Green

# Update PowerShell $PROFILE
if (-not $NoProfileUpdate) {
    if (-not $PROFILE) {
        Write-Warning "PowerShell `$PROFILE path is not set."
    }
    else {
        $profileDir = Split-Path $PROFILE
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }

        if (-not (Test-Path $PROFILE)) {
            New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        }

        $importStatement = "Import-Module Kiwii"
        $initStatement = "Initialize-Kiwii"

        $profileContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
        if (-not $profileContent) { $profileContent = "" }

        if ($profileContent -notmatch "Import-Module Kiwii") {
            Add-Content -Path $PROFILE -Value "`n# Kiwii PowerShell Customization`n$importStatement`n$initStatement`n"
            Write-Host "✓ Added Kiwii startup commands to `$PROFILE ($PROFILE)" -ForegroundColor Green
        }
        else {
            Write-Host "i Kiwii is already configured in `$PROFILE" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "🎉 Installation complete!" -ForegroundColor Green
Write-Host "Restart your terminal or run: " -NoNewline
Write-Host "Import-Module Kiwii; Initialize-Kiwii" -ForegroundColor Yellow
Write-Host ""

# Kiwii Uninstaller Script (Uninstall.ps1)
# Uninstalls Kiwii module from PowerShell modules directory and cleans up $PROFILE

[CmdletBinding()]
param(
    [switch]$RemoveConfig,
    [string]$CustomModulePath
)

$ErrorActionPreference = 'Stop'

Write-Host "Uninstalling Kiwii PowerShell Toolkit..." -ForegroundColor Yellow

# Determine module directory
if ($CustomModulePath) {
    $targetDir = $CustomModulePath
}
else {
    if ($IsWindows) {
        $targetDir = Join-Path $HOME "Documents\PowerShell\Modules\Kiwii"
    }
    else {
        $targetDir = Join-Path $HOME ".local/share/powershell/Modules/Kiwii"
    }
}

# Remove module directory
if (Test-Path $targetDir) {
    Remove-Item -Path $targetDir -Recurse -Force
    Write-Host "✓ Removed Kiwii module directory from $targetDir" -ForegroundColor Green
}
else {
    Write-Host "i Kiwii module directory not found at $targetDir" -ForegroundColor Cyan
}

# Clean up $PROFILE
if ($PROFILE -and (Test-Path $PROFILE)) {
    $content = Get-Content -Path $PROFILE
    $newContent = $content | Where-Object {
        $_ -and
        $_ -notmatch "Import-Module Kiwii" -and
        $_ -notmatch "Initialize-Kiwii" -and
        $_ -notmatch "# Kiwii PowerShell Customization"
    }

    if ($newContent) {
        Set-Content -Path $PROFILE -Value $newContent -Encoding UTF8
    }
    else {
        Clear-Content -Path $PROFILE
    }
    Write-Host "✓ Cleaned up Kiwii lines from `$PROFILE ($PROFILE)" -ForegroundColor Green
}

# Optional: Remove configuration directory (~/.kiwii)
if ($RemoveConfig) {
    $configDir = Join-Path $HOME ".kiwii"
    if (Test-Path $configDir) {
        Remove-Item -Path $configDir -Recurse -Force
        Write-Host "✓ Removed Kiwii configuration directory ($configDir)" -ForegroundColor Green
    }
}

Write-Host "🎉 Kiwii has been successfully uninstalled!" -ForegroundColor Green

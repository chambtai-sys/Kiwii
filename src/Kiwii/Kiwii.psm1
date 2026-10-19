# Kiwii - PowerShell Customization & Productivity Toolkit
# Module Version: 0.1.0-beta

$script:ConfigPath = Join-Path $HOME ".kiwii" "config.json"

$script:DefaultConfig = @{
    Theme               = "Kiwi"
    PromptStyle         = "Fancy"
    ShowBannerOnStartup = $true
    EnableAliases       = $true
    EnableGitInfo       = $true
}

$script:Themes = @{
    "Kiwi" = @{
        Primary   = "Green"
        Secondary = "DarkYellow"
        Accent    = "Cyan"
        Error     = "Red"
        Success   = "Green"
        Text      = "White"
        Muted     = "DarkGray"
    }
    "Cyberpunk" = @{
        Primary   = "Magenta"
        Secondary = "Yellow"
        Accent    = "Cyan"
        Error     = "Red"
        Success   = "Green"
        Text      = "White"
        Muted     = "DarkGray"
    }
    "Ocean" = @{
        Primary   = "Cyan"
        Secondary = "Blue"
        Accent    = "DarkCyan"
        Error     = "Red"
        Success   = "Green"
        Text      = "White"
        Muted     = "DarkGray"
    }
    "Dracula" = @{
        Primary   = "DarkMagenta"
        Secondary = "Magenta"
        Accent    = "Cyan"
        Error     = "Red"
        Success   = "Green"
        Text      = "White"
        Muted     = "DarkGray"
    }
    "Minimal" = @{
        Primary   = "Gray"
        Secondary = "DarkGray"
        Accent    = "White"
        Error     = "Red"
        Success   = "Green"
        Text      = "White"
        Muted     = "DarkGray"
    }
}

function Get-KiwiiConfig {
    [CmdletBinding()]
    param()

    if (Test-Path $script:ConfigPath) {
        try {
            $json = Get-Content -Path $script:ConfigPath -Raw -ErrorAction Stop
            $loadedConfig = $json | ConvertFrom-Json
            $config = $script:DefaultConfig.Clone()
            foreach ($prop in $loadedConfig.psobject.properties) {
                $config[$prop.Name] = $prop.Value
            }
            return $config
        }
        catch {
            return $script:DefaultConfig.Clone()
        }
    }
    else {
        return $script:DefaultConfig.Clone()
    }
}

function Set-KiwiiConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Theme,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Fancy", "Minimal", "Powerline", "Classic")]
        [string]$PromptStyle,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]$ShowBannerOnStartup,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]$EnableAliases,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]$EnableGitInfo
    )

    $config = Get-KiwiiConfig
    if ($PSBoundParameters.ContainsKey('Theme')) {
        if (-not $script:Themes.ContainsKey($Theme)) {
            Write-Error "Invalid theme '$Theme'. Available themes: $($script:Themes.Keys -join ', ')"
            return
        }
        $config.Theme = $Theme
    }
    if ($PSBoundParameters.ContainsKey('PromptStyle')) { $config.PromptStyle = $PromptStyle }
    if ($PSBoundParameters.ContainsKey('ShowBannerOnStartup')) { $config.ShowBannerOnStartup = $ShowBannerOnStartup }
    if ($PSBoundParameters.ContainsKey('EnableAliases')) { $config.EnableAliases = $EnableAliases }
    if ($PSBoundParameters.ContainsKey('EnableGitInfo')) { $config.EnableGitInfo = $EnableGitInfo }

    $configDir = Split-Path $script:ConfigPath
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    $config | ConvertTo-Json | Set-Content -Path $script:ConfigPath -Encoding UTF8
    Write-Host "Kiwii configuration saved to $script:ConfigPath" -ForegroundColor Green
}

function Show-KiwiiBanner {
    [CmdletBinding()]
    param(
        [switch]$RawText
    )

    $bannerText = @"
  _  ___          _ _
 | |/ (_)        (_)(_)  [BETA]
 | ' / _ _  _  _  _ _    v0.1.0-beta
 |  < | | || || || | |   PowerShell Customization Toolkit
 |_|\_|_|\_,_|\_,_|_|_|  https://github.com/kiwii-ps
"@

    if ($RawText) {
        return $bannerText
    }

    $config = Get-KiwiiConfig
    $themeName = if ($script:Themes.ContainsKey($config.Theme)) { $config.Theme } else { "Kiwi" }
    $theme = $script:Themes[$themeName]

    Write-Host ""
    Write-Host "  _  ___          _ _ " -ForegroundColor $theme.Primary -NoNewline
    Write-Host "  "
    Write-Host " | |/ (_)        (_)(_)" -ForegroundColor $theme.Primary -NoNewline
    Write-Host "  [BETA]" -ForegroundColor Yellow
    Write-Host " | ' / _ _  _  _  _ _ " -ForegroundColor $theme.Primary -NoNewline
    Write-Host "   v0.1.0-beta" -ForegroundColor $theme.Secondary
    Write-Host " |  < | | || || || | |" -ForegroundColor $theme.Primary -NoNewline
    Write-Host "   PowerShell Customization Toolkit" -ForegroundColor $theme.Accent
    Write-Host " |_|\_|_|\_,_|\_,_|_|_|" -ForegroundColor $theme.Primary -NoNewline
    Write-Host "   Type " -NoNewline -ForegroundColor $theme.Muted
    Write-Host "Invoke-KiwiiConfig" -NoNewline -ForegroundColor $theme.Accent
    Write-Host " to customize" -ForegroundColor $theme.Muted
    Write-Host ""
}

function Get-KiwiiTheme {
    [CmdletBinding()]
    param()

    $config = Get-KiwiiConfig
    [PSCustomObject]@{
        CurrentTheme    = $config.Theme
        AvailableThemes = $script:Themes.Keys | Sort-Object
        Details         = $script:Themes
    }
}

function Set-KiwiiTheme {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )

    if (-not $script:Themes.ContainsKey($Name)) {
        Write-Error "Theme '$Name' not found. Available themes: $($script:Themes.Keys -join ', ')"
        return
    }

    Set-KiwiiConfig -Theme $Name
    Write-Host "Kiwii theme updated to '$Name'!" -ForegroundColor Green
    Set-KiwiiPrompt
}

function Get-GitBranchInfo {
    try {
        $gitDir = git rev-parse --git-dir 2>$null
        if ($LASTEXITCODE -eq 0 -and $gitDir) {
            $branch = git symbolic-ref --short HEAD 2>$null
            if (-not $branch) {
                $branch = git rev-parse --short HEAD 2>$null
            }
            if ($branch) {
                $status = git status --porcelain 2>$null
                $isDirty = $status.Count -gt 0
                return @{
                    Branch  = $branch
                    IsDirty = $isDirty
                }
            }
        }
    }
    catch {}
    return $null
}

function Set-KiwiiPrompt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Fancy", "Minimal", "Powerline", "Classic")]
        [string]$Style
    )

    if ($Style) {
        Set-KiwiiConfig -PromptStyle $Style
    }

    $config = Get-KiwiiConfig
    $selectedStyle = if ($Style) { $Style } else { $config.PromptStyle }

    $promptScript = {
        $lastStatus = $?
        $config = Get-KiwiiConfig
        $themeName = if ($script:Themes.ContainsKey($config.Theme)) { $config.Theme } else { "Kiwi" }
        $theme = $script:Themes[$themeName]

        # Format location
        $cwd = (Get-Location).Path
        $homeDir = $HOME
        if ($cwd.StartsWith($homeDir)) {
            $cwd = "~" + $cwd.Substring($homeDir.Length)
        }

        # Status symbol
        $statusSymbol = if ($lastStatus) { "✓" } else { "✗" }
        $statusColor = if ($lastStatus) { $theme.Success } else { $theme.Error }

        # Git info
        $gitStr = ""
        if ($config.EnableGitInfo) {
            $gitInfo = Get-GitBranchInfo
            if ($gitInfo) {
                $dirtySymbol = if ($gitInfo.IsDirty) { "*" } else { "" }
                $gitStr = " ($($gitInfo.Branch)$dirtySymbol)"
            }
        }

        switch ($config.PromptStyle) {
            "Minimal" {
                Write-Host "🥝 $cwd" -NoNewline -ForegroundColor $theme.Primary
                if ($gitStr) { Write-Host $gitStr -NoNewline -ForegroundColor $theme.Secondary }
                Write-Host " > " -NoNewline -ForegroundColor $theme.Accent
            }
            "Powerline" {
                Write-Host " $cwd " -NoNewline -ForegroundColor White -BackgroundColor $theme.Primary
                if ($gitStr) {
                    Write-Host " $gitStr " -NoNewline -ForegroundColor Black -BackgroundColor $theme.Secondary
                }
                Write-Host " " -NoNewline
            }
            "Classic" {
                Write-Host "PS $cwd" -NoNewline -ForegroundColor $theme.Primary
                if ($gitStr) { Write-Host $gitStr -NoNewline -ForegroundColor $theme.Secondary }
                Write-Host "> " -NoNewline -ForegroundColor $theme.Text
            }
            Default { # "Fancy"
                Write-Host "[" -NoNewline -ForegroundColor $theme.Muted
                Write-Host $statusSymbol -NoNewline -ForegroundColor $statusColor
                Write-Host "] " -NoNewline -ForegroundColor $theme.Muted
                Write-Host "🥝 Kiwii " -NoNewline -ForegroundColor $theme.Primary
                Write-Host "$cwd" -NoNewline -ForegroundColor $theme.Accent
                if ($gitStr) { Write-Host $gitStr -NoNewline -ForegroundColor $theme.Secondary }
                Write-Host "`n❯ " -NoNewline -ForegroundColor $theme.Primary
            }
        }

        return " "
    }

    Set-Item -Path function:global:prompt -Value $promptScript
}

function Set-KiwiiAlias {
    [CmdletBinding()]
    param()

    $aliases = @{
        "ll"    = "Get-ChildItem"
        "la"    = "Get-ChildItem -Force"
        "g"     = "git"
        "gs"    = "git status"
        "gp"    = "git pull"
        "gpush" = "git push"
    }

    foreach ($aliasName in $aliases.Keys) {
        $target = $aliases[$aliasName]
        if (-not (Get-Alias -Name $aliasName -ErrorAction SilentlyContinue)) {
            try {
                Set-Alias -Name $aliasName -Value $target -Scope Global -ErrorAction SilentlyContinue
            }
            catch {}
        }
    }

    # Custom function aliases
    if (-not (Get-Command -Name "touch" -ErrorAction SilentlyContinue)) {
        function global:touch {
            param([string[]]$Paths)
            foreach ($p in $Paths) {
                if (-not (Test-Path $p)) {
                    New-Item -ItemType File -Path $p | Out-Null
                }
                else {
                    (Get-Item $p).LastWriteTime = Get-Date
                }
            }
        }
    }

    if (-not (Get-Command -Name "reload" -ErrorAction SilentlyContinue)) {
        function global:reload {
            if ($PROFILE -and (Test-Path $PROFILE)) {
                . $PROFILE
                Write-Host "Profile reloaded!" -ForegroundColor Green
            }
            else {
                Write-Warning "Profile file not found at $PROFILE"
            }
        }
    }
}

function Get-KiwiiAlias {
    [CmdletBinding()]
    param()

    [PSCustomObject]@{
        "ll"     = "Get-ChildItem"
        "la"     = "Get-ChildItem -Force"
        "g"      = "git"
        "gs"     = "git status"
        "gp"     = "git pull"
        "gpush"  = "git push"
        "touch"  = "Creates or updates timestamp of file(s)"
        "reload" = "Reloads current $PROFILE"
    }
}

function Invoke-KiwiiConfig {
    [CmdletBinding()]
    param()

    $config = Get-KiwiiConfig
    Write-Host "--- Kiwii Configuration ---" -ForegroundColor Cyan
    $config.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Host "  $($_.Key)": -NoNewline -ForegroundColor Yellow
        Write-Host " $($_.Value)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "To update settings, run: Set-KiwiiConfig -Theme <ThemeName> -PromptStyle <Style>" -ForegroundColor Gray
}

function Initialize-Kiwii {
    [CmdletBinding()]
    param()

    $config = Get-KiwiiConfig
    if ($config.ShowBannerOnStartup) {
        Show-KiwiiBanner
    }
    if ($config.EnableAliases) {
        Set-KiwiiAlias
    }
    Set-KiwiiPrompt -Style $config.PromptStyle
}

Export-ModuleMember -Function @(
    "Show-KiwiiBanner",
    "Get-KiwiiConfig",
    "Set-KiwiiConfig",
    "Get-KiwiiTheme",
    "Set-KiwiiTheme",
    "Set-KiwiiPrompt",
    "Set-KiwiiAlias",
    "Get-KiwiiAlias",
    "Invoke-KiwiiConfig",
    "Initialize-Kiwii"
)

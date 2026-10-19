# Kiwii Pester Unit & Integration Tests

Describe "Kiwii Module" {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot "../src/Kiwii/Kiwii.psd1"
        Import-Module $modulePath -Force
    }

    Context "Module Exported Functions" {
        It "Exports expected functions" {
            $exported = (Get-Module Kiwii).ExportedFunctions.Keys
            $expected = @(
                'Show-KiwiiBanner',
                'Get-KiwiiConfig',
                'Set-KiwiiConfig',
                'Get-KiwiiTheme',
                'Set-KiwiiTheme',
                'Set-KiwiiPrompt',
                'Set-KiwiiAlias',
                'Get-KiwiiAlias',
                'Invoke-KiwiiConfig',
                'Initialize-Kiwii'
            )
            foreach ($func in $expected) {
                $exported | Should -Contain $func
            }
        }
    }

    Context "Show-KiwiiBanner" {
        It "Outputs banner with [BETA] tag when RawText switch is specified" {
            $banner = Show-KiwiiBanner -RawText
            $banner | Should -Match "\[BETA\]"
            $banner | Should -Match "v0.1.0-beta"
            $banner | Should -Match "PowerShell Customization Toolkit"
        }
    }

    Context "Theme & Configuration Management" {
        It "Retrieves available themes including Kiwi, Cyberpunk, Ocean, Dracula, Minimal" {
            $themes = Get-KiwiiTheme
            $themes.AvailableThemes | Should -Contain "Kiwi"
            $themes.AvailableThemes | Should -Contain "Cyberpunk"
            $themes.AvailableThemes | Should -Contain "Ocean"
            $themes.AvailableThemes | Should -Contain "Dracula"
            $themes.AvailableThemes | Should -Contain "Minimal"
        }

        It "Updates configuration when Set-KiwiiConfig is called" {
            Set-KiwiiConfig -PromptStyle "Minimal" -Theme "Cyberpunk"
            $config = Get-KiwiiConfig
            $config.PromptStyle | Should -Be "Minimal"
            $config.Theme | Should -Be "Cyberpunk"

            # Reset back to default
            Set-KiwiiConfig -PromptStyle "Fancy" -Theme "Kiwi"
        }
    }

    Context "Aliases & Prompt Customization" {
        It "Sets up productivity aliases" {
            Set-KiwiiAlias
            $aliases = Get-KiwiiAlias
            $aliases.ll | Should -Be "Get-ChildItem"
            $aliases.g | Should -Be "git"
        }

        It "Configures custom prompt function" {
            Set-KiwiiPrompt -Style "Minimal"
            (Get-Command prompt -ErrorAction SilentlyContinue) | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Installer & Uninstaller Scripts" {
    Context "Install.ps1 & Uninstall.ps1 execution" {
        It "Installs Kiwii module to a custom target directory and uninstalls cleanly" {
            $installScript = Join-Path $PSScriptRoot "../Install.ps1"
            $uninstallScript = Join-Path $PSScriptRoot "../Uninstall.ps1"
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "kiwii_pester_test"

            try {
                # Test installation
                & $installScript -CustomModulePath $tempDir -NoProfileUpdate
                (Test-Path $tempDir) | Should -Be $true
                (Test-Path (Join-Path $tempDir "Kiwii.psm1")) | Should -Be $true
                (Test-Path (Join-Path $tempDir "Kiwii.psd1")) | Should -Be $true

                # Test uninstallation
                & $uninstallScript -CustomModulePath $tempDir
                (Test-Path $tempDir) | Should -Be $false
            }
            finally {
                if (Test-Path $tempDir) {
                    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}

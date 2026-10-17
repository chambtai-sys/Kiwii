#
# Module manifest for module 'Kiwii'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Kiwii.psm1'

# Version number of this module.
ModuleVersion = '0.1.0'

# Supported PSEditions
CompatiblePSEditions = @('Core', 'Desktop')

# ID used to uniquely identify this module
GUID = 'a3b84f2c-901d-4f05-b12e-8c3d702e0b11'

# Author of this module
Author = 'Kiwii Team'

# Company or vendor of this module
CompanyName = 'Kiwii'

# Copyright statement for this module
Copyright = '(c) Kiwii. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Kiwii is a PowerShell toolkit that enhances and customizes the PowerShell CLI experience.'

# Functions to export from this module
FunctionsToExport = @(
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

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = @()

# Private data to pass to the module specified in RootModule
PrivateData = @{
    PSData = @{
        # Tags applied to this module.
        Tags = @('PowerShell', 'Prompt', 'Customization', 'Theme', 'Aliases', 'Beta')

        # A URL to the license for this module.
        LicenseUri = 'https://opensource.org/licenses/MIT'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/kiwii-ps'

        # ReleaseNotes of this module
        ReleaseNotes = '0.1.0-beta: Initial beta release of Kiwii PowerShell toolkit.'
    }
}

}

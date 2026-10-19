# 🥝 Kiwii

> **A modern, flexible PowerShell toolkit designed to make your terminal experience better, faster, and more customizable.**

```
  _  ___          _ _
 | |/ (_)        (_)(_)  [BETA]
 | ' / _ _  _  _  _ _    v0.1.0-beta
 |  < | | || || || | |   PowerShell Customization Toolkit
 |_|\_|_|\_,_|\_,_|_|_|  https://github.com/kiwii-ps
```

[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)](https://microsoft.com/powershell)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)]()
[![Status](https://img.shields.io/badge/status-BETA-yellow.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## 🌟 Overview

**Kiwii** transforms your PowerShell CLI with vibrant themes, git-aware prompt styles, productivity aliases, and profile configuration management. Whether you're on Windows, Linux, or macOS, Kiwii delivers a responsive and stylish terminal environment out of the box.

---

## ✨ Features

- 🎨 **Multiple Color Themes**: Choose from `Kiwi`, `Cyberpunk`, `Ocean`, `Dracula`, and `Minimal`.
- ⚡ **Git Integration**: Live Git status and branch indicators built directly into your prompt.
- 🚀 **Productivity Boosters**: Essential aliases (`ll`, `la`, `g`, `gs`, `gp`, `gpush`, `touch`, `reload`).
- 🛠️ **Configurable Prompts**: Swap between `Fancy`, `Minimal`, `Powerline`, and `Classic` styles instantly.
- 📦 **Native PowerShell Installer (`.ps1`)**: Simple, single-script installer with auto `$PROFILE` integration.
- 🧪 **Beta Tested**: Modular architecture covered by unit and integration tests.

---

## 🚀 Quick Start & Installation

### Option 1: Run the `.ps1` Installer

Clone or download the repo and run `Install.ps1` in PowerShell:

```powershell
.\Install.ps1
```

Or install non-interactively without modifying `$PROFILE`:

```powershell
.\Install.ps1 -NoProfileUpdate
```

### Option 2: One-Line Remote Installation (PowerShell)

```powershell
Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/kiwii-ps/kiwii/main/Install.ps1")
```

---

## 🎨 Themes & Prompt Customization

Kiwii offers built-in themes and prompt layout styles.

### Change Prompt Style

```powershell
Set-KiwiiPrompt -Style Fancy      # Default dual-line prompt with status & git info
Set-KiwiiPrompt -Style Minimal    # Clean, single-line prompt
Set-KiwiiPrompt -Style Powerline  # Block segment prompt
Set-KiwiiPrompt -Style Classic    # Lightweight standard PS style
```

### Change Color Theme

```powershell
Set-KiwiiTheme Kiwi              # Vibrant signature green theme
Set-KiwiiTheme Cyberpunk         # High-contrast neon magenta & yellow
Set-KiwiiTheme Ocean             # Cool cyan & blue tones
Set-KiwiiTheme Dracula           # Dark mode purple palette
Set-KiwiiTheme Minimal           # Subtle grayscale palette
```

To list all themes:

```powershell
Get-KiwiiTheme
```

---

## 🛠️ Commands & Configuration

| Command | Description |
| :--- | :--- |
| `Show-KiwiiBanner` | Displays the ASCII Kiwii banner with the `[BETA]` tag. |
| `Invoke-KiwiiConfig` | Displays your active configuration settings. |
| `Set-KiwiiConfig` | Updates configuration settings permanently stored in `~/.kiwii/config.json`. |
| `Get-KiwiiTheme` | Displays available themes and active color map. |
| `Set-KiwiiTheme` | Switches active theme and reloads prompt. |
| `Set-KiwiiPrompt` | Switches prompt layout style (`Fancy`, `Minimal`, `Powerline`, `Classic`). |
| `Get-KiwiiAlias` | Shows active Kiwii productivity aliases. |

### Configuration File (`~/.kiwii/config.json`)

Your preferences are saved in your home directory:

```json
{
  "Theme": "Kiwi",
  "PromptStyle": "Fancy",
  "ShowBannerOnStartup": true,
  "EnableAliases": true,
  "EnableGitInfo": true
}
```

---

## ⚡ Built-in Aliases & Helpers

Kiwii loads productivity aliases into your global scope:

- `ll` ➜ `Get-ChildItem`
- `la` ➜ `Get-ChildItem -Force`
- `g` ➜ `git`
- `gs` ➜ `git status`
- `gp` ➜ `git pull`
- `gpush` ➜ `git push`
- `touch <file>` ➜ Creates a file or updates its timestamp
- `reload` ➜ Reloads your current `$PROFILE`

---

## 🗑️ Uninstallation

To remove Kiwii and clean up your `$PROFILE`:

```powershell
.\Uninstall.ps1
```

To also remove configuration files (`~/.kiwii`):

```powershell
.\Uninstall.ps1 -RemoveConfig
```

---

## 🤝 Contributing & Feedback

Kiwii is currently in **[BETA]**. Suggestions, issues, and pull requests are warmly welcomed!

- **License**: MIT

# Quick Start Guide

## 30-Second Setup

```powershell
cd C:\Project\M365-AI-Automation-Toolkit
.\scripts\Utilities\Test-M365DevEnvironment.ps1
code .
```

## In 5 Minutes

1. Open a new PowerShell file in VS Code.
2. Ask GitHub Copilot for the script you want.
3. Copy the suggestion into your file and save it as `.ps1`.
4. Test it with `-WhatIf` first when the script changes anything.

## File You Need

- Read [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for coding standards.
- Reference [GUIDE.md](GUIDE.md) for the full workflow.
- Use [EXAMPLES.md](EXAMPLES.md) for copy-paste examples.

## Common Commands

| Goal | Command |
|------|---------|
| Test environment | `.\scripts\Utilities\Test-M365DevEnvironment.ps1` |
| Open workspace | `code C:\Project\M365-AI-Automation-Toolkit` |
| Preview changes | `.\your-script.ps1 -WhatIf` |
| See verbose output | `.\your-script.ps1 -Verbose` |
| Commit changes | `git add .` then `git commit -m "your message"` |

## Script Template

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Starting..."
    # YOUR CODE HERE
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Success!"
}
catch {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Error: $_" -ForegroundColor Red
    exit 1
}
```

## Get Unstuck

- If Copilot is not suggesting code, reload VS Code and confirm the extension is installed.
- If a script fails to run, add `-Verbose` and check `.github/copilot-instructions.md`.
- If you are not sure where a script belongs, use `scripts/SharePoint/`, `scripts/Graph/`, `scripts/Teams/`, `scripts/EntraID/`, or `scripts/Utilities/`.

## Next Steps

- Read [GUIDE.md](GUIDE.md) for the full workflow.
- Read [EXAMPLES.md](EXAMPLES.md) for real-world examples.
- Read [CONTRIBUTING.md](CONTRIBUTING.md) if you plan to submit changes.
# Contributing to M365 AI Automation Toolkit

Thank you for your interest in contributing! This document provides guidelines for participating in this project.

## Code of Conduct

- Be respectful and constructive in all interactions
- Ask questions before making assumptions
- Test your changes before submitting
- Provide clear documentation for new features

## Getting Started

1. **Fork and Clone** (if applicable) or clone directly:
   ```powershell
   git clone https://github.com/your-org/M365-AI-Automation-Toolkit.git
   cd M365-AI-Automation-Toolkit
   ```

2. **Verify Environment:**
   ```powershell
   .\scripts\Utilities\Test-M365DevEnvironment.ps1
   ```

3. **Create a Feature Branch:**
   ```powershell
   git checkout -b feature/my-new-feature
   ```

## Before You Start

- Check existing scripts in the relevant `scripts/` directory to avoid duplication
- Review `.github/copilot-instructions.md` for standards and patterns
- Understand the folder structure (see GUIDE.md)
- Consider authentication patterns for your workload

## Writing Code

### PowerShell Scripts

1. **Follow the Template**
   - Start with `[CmdletBinding()]` and `param()` block
   - Use `Set-StrictMode -Version Latest`
   - Use `$ErrorActionPreference = "Stop"`
   - Include logging with timestamps
   - Add XML comment help (minimum 2-3 lines)

   ```powershell
   <#
   .SYNOPSIS
   Brief description of what the script does.

   .DESCRIPTION
   Detailed description if needed.

   .PARAMETER SiteUrl
   The SharePoint site URL to connect to.

   .EXAMPLE
   .\Get-SiteInfo.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/example"
   #>
   [CmdletBinding()]
   param(
       [Parameter(Mandatory = $true)]
       [string]$SiteUrl
   )
   ```

2. **Parameter Validation**
   ```powershell
   [Parameter(
       Mandatory = $true,
       ValueFromPipeline = $false,
       HelpMessage = "The SharePoint site URL"
   )]
   [ValidatePattern("^https://")]
   [string]$SiteUrl
   ```

3. **Error Handling**
   ```powershell
   try {
       # Main logic
   }
   catch {
       Write-Log "Operation failed: $($_.Exception.Message)" "ERROR"
       exit 1
   }
   finally {
       # Cleanup
   }
   ```

4. **Logging**
   ```powershell
   function Write-Log {
       param(
           [string]$Message,
           [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
           [string]$Level = "INFO"
       )
       $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
       Write-Host "[$timestamp] [$Level] $Message"
   }
   ```

### Modules

If creating reusable PowerShell modules in `modules/`:
- Use `.psm1` file extension
- Include function manifest (`.psd1`)
- Document all public functions with XML comments
- Test module can be imported: `Import-Module .\modules\MyModule.psm1`

## Testing Your Changes

### Mandatory Tests

1. **Syntax Validation**
   ```powershell
   Test-Path -Path "path/to/your/script.ps1" -PathType Leaf
   ```

2. **Run Environment Test**
   ```powershell
   .\scripts\Utilities\Test-M365DevEnvironment.ps1
   ```

3. **Test Your Script (WhatIf)**
   ```powershell
   .\scripts\YourWorkload\Your-Script.ps1 -SiteUrl "https://test-site" -WhatIf
   ```

4. **Run with Verbose**
   ```powershell
   .\scripts\YourWorkload\Your-Script.ps1 -SiteUrl "https://test-site" -Verbose
   ```

### Optional: Unit Tests

For complex functions, consider adding tests in `tests/`:
```powershell
# tests/Test-MyFunction.ps1
param()

$ErrorActionPreference = "Stop"

# Test case 1
try {
    $result = & (Get-Content -Path ".\scripts\SharePoint\Get-SiteInfo.ps1")
    Write-Host "✓ Script loads without syntax errors" -ForegroundColor Green
} catch {
    Write-Host "✗ Syntax error: $_" -ForegroundColor Red
    exit 1
}
```

Run all tests:
```powershell
Get-ChildItem tests/*.ps1 | ForEach-Object {
    Write-Host "Running $_..."
    & $_.FullName
}
```

## Security Checklist

Before submitting, verify:

- [ ] No hardcoded credentials, passwords, or secrets
- [ ] No API keys or tokens in code
- [ ] Sensitive config is in `.env` or `.gitignore`d files
- [ ] Script validates and sanitizes user input
- [ ] Destructive operations support `-WhatIf`
- [ ] Error messages don't expose sensitive information
- [ ] Script respects principle of least privilege

## Submission Process

### 1. Commit Your Changes

Use clear, descriptive commit messages:
```powershell
git add .
git commit -m "feat: Add SharePoint list deployment script

- Supports JSON list definitions
- Includes field validation
- Supports -WhatIf for safe testing"
```

**Commit Message Format:**
- `feat:` New feature or script
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code restructuring
- `test:` Test additions or updates
- `chore:` Maintenance tasks

### 2. Create a Pull Request

Provide:
- **Title:** Brief description
- **Description:** What changed and why
- **Related Issues:** Link to issue numbers if applicable
- **Testing:** How you tested the changes
- **Screenshots:** If UI-related (not applicable here)

**Example PR Description:**
```
## Description
Adds script to export all SharePoint site collections with storage quota usage.

## Changes
- New script: `scripts/TenantAdministration/Get-SiteCollectionQuota.ps1`
- Example config: `config/examples/quota-export-config.json`
- Updated: GUIDE.md with usage instructions

## Testing
- ✓ Runs without errors
- ✓ Outputs to CSV correctly
- ✓ Handles paging for large tenants
- ✓ Tested with -WhatIf flag

## Security
- ✓ No hardcoded credentials
- ✓ Validates URLs before use
- ✓ Logs all operations
```

### 3. Code Review

- Address feedback promptly
- Keep discussion professional
- Re-test after changes
- Don't force-push to PR branch (if others are reviewing)

### 4. Merge

Once approved:
- Maintainers will merge to main
- Updates will be available in next release

## Directory-Specific Guidelines

### `scripts/SharePoint/`
- Use PnP PowerShell as primary tool
- Prefix functions with `Get-`, `Set-`, `New-`, etc.
- Handle sites with and without custom permissions
- Consider list throttling limits (5,000 items)

### `scripts/Graph/`
- Use Microsoft.Graph PowerShell SDK
- Implement proper permission scoping
- Handle pagination for results > 20 items
- Implement retry logic for throttling

### `scripts/Utilities/`
- Create reusable helper functions
- No tenant-specific logic
- Export publicly useful functions
- Document with examples

### `config/examples/`
- Provide sample configuration files
- Include comments explaining each field
- Make files easy to duplicate and modify
- Never include real secrets

### `docs/`
- Use Markdown format
- Include examples and screenshots
- Keep documentation current
- Link to Microsoft Learn docs

## Coding Standards

### DO

✅ Use meaningful variable names
```powershell
$siteCollections = Get-PnPTenantSite
```

✅ Comment complex logic
```powershell
# Fetch sites in batches to respect API limits
```

✅ Use splatting for multiple parameters
```powershell
$params = @{
    SiteUrl = $url
    Verbose = $true
    ErrorAction = "Stop"
}
Connect-PnPOnline @params
```

✅ Use approved verbs
```powershell
Get-SharePointSite    # ✓
Set-ListItem          # ✓
New-Group             # ✓
Remove-User           # ✓ (but ask for confirmation)
```

### DON'T

❌ Use single-letter variables (except `$i` in loops)
```powershell
$s = $site  # ✗ Avoid
```

❌ Nest too deeply
```powershell
if ($x) {
    if ($y) {
        if ($z) {  # ✗ Too deep
```

❌ Use Write-Host for output (use `return` or Write-Output)
```powershell
Write-Output $result  # ✓
Write-Host $result    # ✗ Unless for logging
```

❌ Ignore errors silently
```powershell
Get-Item $path -ErrorAction SilentlyContinue  # ✗ (usually)
```

## Release Process

1. Update version in comments
2. Update CHANGELOG (if maintained)
3. Tag commit: `git tag v1.0.0`
4. Push: `git push --tags`

## Questions?

- Review GUIDE.md for detailed usage
- Check `.github/copilot-instructions.md` for standards
- Ask in discussions or issues
- Review similar scripts for examples

---

**Thank you for contributing!**

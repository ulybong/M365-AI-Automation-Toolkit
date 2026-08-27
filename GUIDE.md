# M365 AI Automation Toolkit — Developer Guide

## Table of Contents
1. [Quick Start](#quick-start)
2. [Project Structure](#project-structure)
3. [Writing Scripts](#writing-scripts)
4. [Using GitHub Copilot](#using-github-copilot)
5. [MCP Servers](#mcp-servers)
6. [Authentication Patterns](#authentication-patterns)
7. [Testing & Validation](#testing--validation)
8. [Common Tasks](#common-tasks)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Minimum Setup (5 minutes)

1. Clone or navigate to the repository:
   ```powershell
   cd C:\Project\M365-AI-Automation-Toolkit
   ```

2. Verify environment:
   ```powershell
   .\scripts\Utilities\Test-M365DevEnvironment.ps1
   ```

3. Open in VS Code:
   ```powershell
   code .
   ```

4. Start writing scripts in the appropriate `scripts/` subdirectory.

---

## Project Structure

```
M365-AI-Automation-Toolkit/
├── .github/
│   └── copilot-instructions.md    # Copilot guidelines & standards
├── .vscode/
│   ├── mcp.json                    # MCP server configuration
│   ├── extensions.json             # Recommended extensions
│   └── settings.json               # Workspace settings
├── scripts/
│   ├── SharePoint/                 # SharePoint Online scripts
│   ├── Graph/                      # Microsoft Graph scripts
│   ├── Teams/                      # Microsoft Teams scripts
│   ├── EntraID/                    # Entra ID / Azure AD scripts
│   ├── OneDrive/                   # OneDrive scripts
│   ├── PowerPlatform/              # Power Apps / Power Automate scripts
│   ├── ExchangeOnline/             # Exchange Online scripts
│   ├── TenantAdministration/       # Tenant-wide admin scripts
│   └── Utilities/                  # Helper scripts & tools
├── modules/                        # Reusable PowerShell modules
├── config/
│   └── examples/                   # Sample configuration files
├── docs/                           # Documentation
├── tests/                          # Test scripts & validation
├── output/                         # Generated output files
├── logs/                           # Script execution logs
├── README.md                       # Project overview
├── GUIDE.md                        # This file
└── .gitignore                      # Git ignore rules
```

### When to Use Each Directory

| Directory | Purpose | Example |
|-----------|---------|---------|
| `scripts/SharePoint/` | SharePoint Online automation | List management, content deployment |
| `scripts/Graph/` | Microsoft Graph API operations | User management, mail, calendar |
| `scripts/Teams/` | Teams channel & team operations | Create teams, manage channels |
| `scripts/EntraID/` | Azure Entra ID / Azure AD operations | Manage users, groups, roles |
| `scripts/OneDrive/` | OneDrive & personal storage | Quota management, file operations |
| `scripts/PowerPlatform/` | Power Apps, Power Automate, Power BI | App management, flow operations |
| `scripts/ExchangeOnline/` | Exchange Online mailbox operations | Mailbox configuration, rules |
| `scripts/TenantAdministration/` | Tenant-wide settings | DLP, retention, security |
| `scripts/Utilities/` | Shared helper functions & tools | Logging, validation, common tasks |
| `modules/` | Reusable PowerShell modules | Custom PSM1 module files |
| `config/examples/` | Sample configs & templates | Example parameter files |
| `tests/` | Test & validation scripts | Unit tests, integration tests |

---

## Writing Scripts

### Template: Basic Reusable Script

Create new scripts in the appropriate `scripts/` subdirectory:

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "SharePoint site URL")]
    [string]$SiteUrl,

    [Parameter(Mandatory = $false)]
    [string]$ListName = "Documents",

    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

try {
    Write-Log "Starting script for site: $SiteUrl"

    # Validate parameters
    if (-not $SiteUrl.StartsWith("https://")) {
        throw "SiteUrl must be a valid HTTPS URL"
    }

    # Main logic
    if ($WhatIf) {
        Write-Log "WhatIf mode: Would connect to $SiteUrl and list '$ListName'"
    } else {
        # Actual operations
        Write-Log "Connecting to SharePoint Online"
        # ... implementation
    }

    Write-Log "Script completed successfully" "SUCCESS"
}
catch {
    Write-Log "Error: $($_.Exception.Message)" "ERROR"
    exit 1
}
```

### Script Checklist

- [ ] Function uses `[CmdletBinding()]`
- [ ] Parameters have `[Parameter()]` attributes with descriptions
- [ ] Set `Set-StrictMode -Version Latest`
- [ ] Set `$ErrorActionPreference = "Stop"`
- [ ] Include logging/verbose output
- [ ] Use `try/catch` for error handling
- [ ] Support `-WhatIf` for destructive operations
- [ ] Avoid hardcoded values (use parameters instead)
- [ ] Include meaningful error messages
- [ ] Add comments explaining non-obvious logic
- [ ] Tested locally before committing

---

## Using GitHub Copilot

### Installation

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "GitHub Copilot"
4. Install both:
   - **GitHub Copilot** (main extension)
   - **GitHub Copilot Chat** (chat interface)

### Getting AI Assistance

#### Method 1: Inline Suggestions
Start typing a function signature, and Copilot will suggest completions:

```powershell
function Get-AllSharePointSites {
    # Copilot will suggest the implementation
}
```

Press `Tab` to accept suggestions, `Esc` to dismiss.

#### Method 2: Copilot Chat
1. Open Copilot Chat: `Ctrl+Shift+I`
2. Ask in natural language:
   ```
   Write a PowerShell function to get all SharePoint site collections 
   using PnP PowerShell with error handling and logging
   ```
3. Review the suggestion and copy/modify as needed

#### Best Prompts for This Toolkit

✅ **Good:**
```
Write a reusable PowerShell function that lists all users in an Entra ID group. 
Use Microsoft.Graph module, include parameter validation, error handling, and -WhatIf support.
```

✅ **Good:**
```
I have a CSV file with site URLs in column A and list names in column B. 
Write a script that connects to each site and exports the list metadata. 
Use PnP PowerShell and log all operations.
```

❌ **Avoid:**
```
Write me a script
```

### Copilot Standards in This Repo

Copilot will follow rules in `.github/copilot-instructions.md`:
- Prefer `PnP.PowerShell` for SharePoint operations
- Prefer `Microsoft.Graph` for Graph API calls
- Use `CLI for Microsoft 365` when simpler
- Never hardcode secrets or credentials
- Always include proper error handling
- Require explicit approval for destructive operations

---

## MCP Servers

MCP (Model Context Protocol) servers extend Copilot with real-time knowledge of specific tools.

### Available MCP Servers

1. **PnP PowerShell MCP Server**
   - Provides PnP PowerShell cmdlet reference
   - Reads available commands and parameters
   - Read-only mode (safe for exploration)

2. **CLI for Microsoft 365 MCP Server**
   - Provides `m365` CLI command reference
   - Helps with m365 CLI syntax and options

### How to Use MCP

1. Open Copilot Chat (`Ctrl+Shift+I`)
2. Ask about available commands:
   ```
   What PnP PowerShell cmdlets are available for managing site columns?
   ```
3. Ask for examples:
   ```
   Show me an example of using Connect-PnPOnline with certificate authentication
   ```

### Checking MCP Status

In VS Code terminal:
```powershell
Get-Command pnp-powershell-mcp-server
m365 --help  # Should work if CLI MCP is available
```

If MCP servers don't appear:
1. Ensure `.vscode/mcp.json` is valid JSON
2. Reload VS Code window (`Ctrl+R` or Cmd+R on Mac)
3. Check VS Code output panel for errors

---

## Authentication Patterns

### Local Development (Interactive)

```powershell
# PnP PowerShell with interactive login
Connect-PnPOnline -Url "https://tenant.sharepoint.com/sites/example" -Interactive

# Microsoft Graph with interactive login
Connect-MgGraph -Scopes "User.Read", "Group.Read.All"
```

### Automated / Production (Certificate)

```powershell
# PnP PowerShell with certificate
$cert = Get-Item "Cert:\CurrentUser\My\<thumbprint>"
Connect-PnPOnline `
    -Url "https://tenant.sharepoint.com/sites/example" `
    -ClientId "00000000-0000-0000-0000-000000000000" `
    -Tenant "tenant.onmicrosoft.com" `
    -Certificate $cert
```

### Entra App Registration Setup

1. Navigate to Azure Portal → App registrations
2. Click "+ New registration"
3. Provide name, select supported account types
4. Configure API permissions (see specific workload scripts)
5. Create a certificate or client secret
6. Save: Application ID, Tenant ID, Certificate thumbprint/secret

**Security note:** Never commit credentials. Store in Azure Key Vault or local secrets manager.

---

## Testing & Validation

### Run Environment Validation

```powershell
.\scripts\Utilities\Test-M365DevEnvironment.ps1
```

Expected output should show PASS for all components.

### Test Your Script Locally

#### Option 1: Dry Run with -WhatIf
```powershell
.\scripts\SharePoint\Deploy-List.ps1 `
    -SiteUrl "https://tenant.sharepoint.com/sites/test" `
    -ListDefinition "config/examples/list-config.json" `
    -WhatIf
```

#### Option 2: Verbose Output
```powershell
.\scripts\SharePoint\Deploy-List.ps1 `
    -SiteUrl "https://tenant.sharepoint.com/sites/test" `
    -ListDefinition "config/examples/list-config.json" `
    -Verbose
```

#### Option 3: Create Test Cases
Place test scripts in `tests/`:

```powershell
# tests/Test-ListDeployment.ps1
param($SiteUrl = "https://tenant.sharepoint.com/sites/test")

try {
    Write-Host "Testing list deployment..."
    
    & .\scripts\SharePoint\Deploy-List.ps1 `
        -SiteUrl $SiteUrl `
        -ListDefinition "config/examples/list-config.json" `
        -WhatIf
    
    Write-Host "✓ Test passed: Script runs without errors" -ForegroundColor Green
} catch {
    Write-Host "✗ Test failed: $_" -ForegroundColor Red
    exit 1
}
```

Run tests:
```powershell
.\tests\Test-ListDeployment.ps1
```

---

## Common Tasks

### Task 1: Deploy a SharePoint List

**Goal:** Create a list in SharePoint using a definition file.

**Steps:**
1. Create `config/examples/list-definition.json`:
   ```json
   {
     "Title": "Projects",
     "Description": "Active projects",
     "BaseTemplate": "GenericList",
     "Fields": [
       { "Name": "ProjectName", "Type": "Text", "Required": true },
       { "Name": "Status", "Type": "Choice", "Choices": ["Active", "Closed"] }
     ]
   }
   ```

2. Ask Copilot in Chat:
   ```
   Write a PnP PowerShell script to create a SharePoint list from a JSON definition file.
   Include error handling and log all operations. Put it in scripts/SharePoint/
   ```

3. Save as `scripts/SharePoint/New-SPListFromJson.ps1`

4. Test:
   ```powershell
   .\scripts\SharePoint\New-SPListFromJson.ps1 `
       -SiteUrl "https://tenant.sharepoint.com/sites/example" `
       -JsonPath "config/examples/list-definition.json" `
       -WhatIf
   ```

### Task 2: Export User Data from Entra ID

**Goal:** Export all users with specific properties to CSV.

**Steps:**
1. Ask Copilot:
   ```
   Write a Microsoft.Graph PowerShell script to export all users from Entra ID 
   to CSV, including Name, Email, Last Login. Include filtering and pagination.
   ```

2. Save as `scripts/EntraID/Export-EntraUsers.ps1`

3. Use:
   ```powershell
   .\scripts\EntraID\Export-EntraUsers.ps1 `
       -OutputPath "output/entra-users.csv" `
       -Filter "accountEnabled eq true"
   ```

### Task 3: Schedule Script Execution

**Goal:** Run a script via Task Scheduler at specific times.

**Steps:**
1. Create a wrapper script `scripts/Utilities/Run-Scheduled.ps1`:
   ```powershell
   [CmdletBinding()]
   param(
       [string]$ScriptPath,
       [hashtable]$Parameters
   )
   
   Set-StrictMode -Version Latest
   $ErrorActionPreference = "Stop"
   
   $logFile = "logs/$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
   
   try {
       & $ScriptPath @Parameters | Tee-Object -FilePath $logFile
   } catch {
       "ERROR: $_" | Tee-Object -Append -FilePath $logFile
       exit 1
   }
   ```

2. Create a Windows Task Scheduler task pointing to this wrapper with parameters.

---

## Best Practices

### Code Quality
- ✅ Use `Set-StrictMode -Version Latest` at the top of all scripts
- ✅ Use `[CmdletBinding()]` in all functions
- ✅ Add parameter validation attributes
- ✅ Include XML comments for public functions
- ✅ Use approved PowerShell verbs (Get-, Set-, New-, Remove-, etc.)
- ✅ Keep functions under 50 lines (single responsibility)

### Error Handling
- ✅ Always use `try/catch/finally` in main script
- ✅ Provide meaningful error messages
- ✅ Log errors to file and console
- ✅ Use `$PSCmdlet.ThrowTerminatingError()` for functions
- ❌ Avoid silent error suppression (`-ErrorAction SilentlyContinue`)

### Security
- ✅ Never hardcode passwords or secrets
- ✅ Never commit `.env` or credential files
- ✅ Use parameter validation to prevent injection
- ✅ Sanitize user input before using in queries
- ✅ Support `-WhatIf` for all destructive operations
- ✅ Require explicit confirmation for critical operations

### Performance
- ✅ Use batch operations when possible (Graph batching, PnP batch)
- ✅ Handle pagination for large result sets
- ✅ Implement retry logic for transient failures
- ✅ Cache results when appropriate
- ✅ Monitor API throttling and implement backoff

### Documentation
- ✅ Add XML comments to all public functions
- ✅ Include examples in function help
- ✅ Document parameters with meaningful descriptions
- ✅ Add README to complex folders
- ✅ Keep GUIDE.md and examples current

### Version Control
- ✅ Commit frequently with clear messages
- ✅ Never commit secrets or sensitive data
- ✅ Use `.gitignore` to exclude logs, output, local configs
- ✅ Tag releases with version numbers
- ✅ Keep branches focused on single features

---

## Troubleshooting

### Problem: Copilot suggestions not appearing

**Solution:**
1. Ensure GitHub Copilot extension is installed and enabled
2. Verify authentication with GitHub account
3. Check that file type is recognized (save as `.ps1` for PowerShell)
4. Reload VS Code window

### Problem: MCP servers not available

**Solution:**
1. Verify `.vscode/mcp.json` is valid JSON:
   ```powershell
   Get-Content .vscode/mcp.json | ConvertFrom-Json
   ```
2. Check PnP MCP installation:
   ```powershell
   Get-Command pnp-powershell-mcp-server
   dotnet tool list -g
   ```
3. Reload VS Code window (Ctrl+R)
4. Check Output panel (View → Output) for errors

### Problem: PowerShell module not found

**Solution:**
```powershell
# Install missing module
Install-Module PnP.PowerShell -Scope CurrentUser -Force

# Verify installation
Get-Module -ListAvailable PnP.PowerShell
```

### Problem: "No .NET SDKs were found"

**Solution:**
1. Install .NET SDK: https://aka.ms/dotnet/download
2. Verify installation:
   ```powershell
   dotnet --list-sdks
   dotnet --version
   ```
3. Close and reopen terminal

### Problem: Script runs but produces no output

**Solution:**
1. Add `-Verbose` flag:
   ```powershell
   .\your-script.ps1 -Verbose
   ```
2. Check `logs/` folder for output files
3. Verify script doesn't suppress output with `Out-Null`
4. Add explicit `Write-Host` statements for debugging

### Problem: Authentication fails

**Solution:**
1. Verify Entra app has required permissions
2. Check tenant ID and app ID are correct
3. For interactive auth, ensure you're using modern auth URL:
   ```powershell
   Connect-PnPOnline -Url "https://tenant.sharepoint.com/sites/example" -Interactive
   ```
4. Check if you need to accept MFA/consent
5. Verify account has access to the resource

---

## Additional Resources

- **Microsoft Graph Documentation:** https://learn.microsoft.com/en-us/graph/
- **PnP PowerShell:** https://pnp.github.io/powershell/
- **CLI for Microsoft 365:** https://pnp.github.io/cli-microsoft365/
- **PowerShell Best Practices:** https://learn.microsoft.com/en-us/powershell/
- **Entra ID Management:** https://learn.microsoft.com/en-us/entra/identity/

---

**Last Updated:** 2026-08-27  
**Version:** 1.0

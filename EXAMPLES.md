# Real-World Script Examples

This file contains copy-paste ready examples for common Microsoft 365 automation tasks.

## Table of Contents

1. [SharePoint](#sharepoint)
2. [Microsoft Graph / Entra ID](#microsoft-graph--entra-id)
3. [Teams](#teams)
4. [Exchange Online](#exchange-online)
5. [General Utilities](#general-utilities)

---

## SharePoint

### Example 1: List All Site Collections and Storage

**File:** `scripts/SharePoint/Get-SiteCollectionInfo.ps1`

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$OutputCsv
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Connect-PnPOnline -Url "https://tenant-admin.sharepoint.com" -Interactive
    $sites = Get-PnPTenantSite -IncludeOneDriveSites:$false

    $results = foreach ($site in $sites) {
        [PSCustomObject]@{
            Title        = $site.Title
            Url          = $site.Url
            Owner        = $site.Owner
            Status       = $site.Status
            StorageUsed  = $site.StorageUsedGB
            StorageQuota = $site.StorageQuotaGB
            CreatedDate  = $site.CreatedDate
        }
    }

    if ($OutputCsv) {
        $results | Export-Csv -Path $OutputCsv -NoTypeInformation
    } else {
        $results | Format-Table -AutoSize
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

**Usage:**

```powershell
.\Get-SiteCollectionInfo.ps1
.\Get-SiteCollectionInfo.ps1 -OutputCsv "output/sites.csv"
```

### Example 2: Bulk Add Users to a SharePoint Group

**File:** `scripts/SharePoint/Add-UsersToGroup.ps1`

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^https://")]
    [string]$SiteUrl,

    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$CsvPath,

    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Connect-PnPOnline -Url $SiteUrl -Interactive
    $users = Import-Csv -Path $CsvPath

    foreach ($user in $users) {
        $email = $user.Email
        if ($WhatIf) {
            Write-Host "[WhatIf] Would add $email to $GroupName"
        } else {
            Add-PnPGroupMember -GroupName $GroupName -LoginName $email
        }
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

**Usage:**

```powershell
.\Add-UsersToGroup.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/project" -GroupName "Project Team" -CsvPath "users.csv" -WhatIf
.\Add-UsersToGroup.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/project" -GroupName "Project Team" -CsvPath "users.csv"
```

---

## Microsoft Graph / Entra ID

### Example 3: Export All Users from Entra ID

**File:** `scripts/EntraID/Export-AllEntraUsers.ps1`

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputCsv,

    [Parameter(Mandatory = $false)]
    [string]$Filter
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Connect-MgGraph -Scopes "User.Read.All" | Out-Null

    $params = @{
        Property = @("id", "displayName", "userPrincipalName", "mail", "accountEnabled", "userType", "createdDateTime")
        All      = $true
    }

    if ($Filter) {
        $params.Filter = $Filter
    }

    $users = Get-MgUser @params
    $results = $users | Select-Object `
        @{ Name = "DisplayName"; Expression = { $_.DisplayName } }, `
        @{ Name = "Email"; Expression = { $_.Mail } }, `
        @{ Name = "UPN"; Expression = { $_.UserPrincipalName } }, `
        @{ Name = "Enabled"; Expression = { $_.AccountEnabled } }, `
        @{ Name = "UserType"; Expression = { $_.UserType } }, `
        @{ Name = "Created"; Expression = { $_.CreatedDateTime } }

    $results | Export-Csv -Path $OutputCsv -NoTypeInformation
    Disconnect-MgGraph
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

**Usage:**

```powershell
.\Export-AllEntraUsers.ps1 -OutputCsv "output/all-users.csv"
.\Export-AllEntraUsers.ps1 -OutputCsv "output/active-users.csv" -Filter "accountEnabled eq true"
```

### Example 4: Create an Entra Security Group and Add Members

**File:** `scripts/EntraID/New-SecurityGroupWithMembers.ps1`

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string]$GroupDescription,

    [Parameter(Mandatory = $true)]
    [string[]]$MemberEmails,

    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Connect-MgGraph -Scopes "Group.Create", "Group.ReadWrite.All", "User.Read.All" | Out-Null

    if ($WhatIf) {
        Write-Host "[WhatIf] Would create group: $GroupName"
        return
    }

    $group = New-MgGroup -DisplayName $GroupName -Description $GroupDescription -MailEnabled:$false -SecurityEnabled:$true -MailNickname ($GroupName -replace ' ', '')

    foreach ($email in $MemberEmails) {
        $user = Get-MgUser -Filter "mail eq '$email'"
        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
    }

    Disconnect-MgGraph
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

---

## Teams

### Example 5: Create a Team and Add Channels

**File:** `scripts/Teams/New-TeamWithChannels.ps1`

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TeamName,

    [Parameter(Mandatory = $true)]
    [string[]]$ChannelNames,

    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Connect-MgGraph -Scopes "Team.Create", "TeamMember.ReadWrite.All" | Out-Null
    $mailNickname = $TeamName -replace ' ', ''
    $team = New-MgTeam -DisplayName $TeamName -MailNickname $mailNickname

    foreach ($channelName in $ChannelNames) {
        New-MgTeamChannel -TeamId $team.Id -DisplayName $channelName | Out-Null
    }

    Disconnect-MgGraph
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

---

## Exchange Online

### Example 6: Bulk Update Mailbox Forwarding

**File:** `scripts/ExchangeOnline/Set-MailboxForwarding.ps1`

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ })]
    [string]$CsvPath,

    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

try {
    Connect-ExchangeOnline -ShowBanner:$false
    $mailboxes = Import-Csv -Path $CsvPath

    foreach ($mb in $mailboxes) {
        if ($WhatIf) {
            Write-Host "[WhatIf] Would set forwarding for $($mb.Email)"
        } else {
            Set-Mailbox -Identity $mb.Email -ForwardingAddress $mb.ForwardTo -DeliverToMailboxAndForward $true
        }
    }

    Disconnect-ExchangeOnline -Confirm:$false
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
```

---

## General Utilities

### Example 7: Logging Utility Module

**File:** `modules/M365Logging.psm1`

```powershell
function New-LogFile {
    [CmdletBinding()]
    param(
        [string]$LogPath = "logs"
    )

    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }

    Join-Path $LogPath "$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Message,

        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO",

        [string]$LogFile
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $output = "[$timestamp] [$Level] $Message"
    Write-Host $output

    if ($LogFile) {
        Add-Content -Path $LogFile -Value $output
    }
}

Export-ModuleMember -Function New-LogFile, Write-Log
```

---

## Tips

- Always test with `-WhatIf` first.
- Use `-Verbose` when debugging.
- Keep logs in the `logs/` folder.

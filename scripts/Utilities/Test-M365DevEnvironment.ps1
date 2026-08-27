[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Add-Result {
    param(
        [string]$Component,
        [ValidateSet("PASS","WARNING","FAIL")][string]$Status,
        [string]$Detail
    )
    [PSCustomObject]@{
        Component = $Component
        Status    = $Status
        Detail    = $Detail
    }
}

$results = New-Object System.Collections.Generic.List[object]

function Get-CommandOutput {
    param(
        [string]$Name,
        [string[]]$Args
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        return @{ Found = $false; Output = "Not installed" }
    }

    try {
        $raw = & $Name @Args 2>&1 | Out-String
        $output = $raw.Trim()
        if (-not $output) {
            $output = "Installed"
        }
        return @{ Found = $true; Output = $output }
    }
    catch {
        return @{ Found = $true; Output = "Installed but check failed: $($_.Exception.Message)" }
    }
}

# PowerShell version
$psv = $PSVersionTable.PSVersion
if ($psv -ge [version]"7.4.0") {
    $results.Add((Add-Result -Component "PowerShell" -Status "PASS" -Detail $psv.ToString()))
} else {
    $results.Add((Add-Result -Component "PowerShell" -Status "FAIL" -Detail "Version $psv. Requires 7.4+"))
}

$git = Get-CommandOutput -Name "git" -Args @("--version")
$results.Add((Add-Result -Component "Git" -Status ($(if($git.Found){"PASS"}else{"WARNING"})) -Detail $git.Output))

$code = Get-CommandOutput -Name "code" -Args @("--version")
$results.Add((Add-Result -Component "VS Code" -Status ($(if($code.Found){"PASS"}else{"WARNING"})) -Detail $code.Output))

$node = Get-CommandOutput -Name "node" -Args @("--version")
$results.Add((Add-Result -Component "Node" -Status ($(if($node.Found){"PASS"}else{"WARNING"})) -Detail $node.Output))

$npm = Get-CommandOutput -Name "npm" -Args @("--version")
$results.Add((Add-Result -Component "npm" -Status ($(if($npm.Found){"PASS"}else{"WARNING"})) -Detail $npm.Output))

$npx = Get-CommandOutput -Name "npx" -Args @("--version")
$results.Add((Add-Result -Component "npx" -Status ($(if($npx.Found){"PASS"}else{"WARNING"})) -Detail $npx.Output))

$dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
if (-not $dotnetCmd) {
    $results.Add((Add-Result -Component "dotnet SDK" -Status "FAIL" -Detail "dotnet not installed"))
} else {
    $sdksRaw = dotnet --list-sdks 2>&1 | Out-String
    $sdks = $sdksRaw.Trim()
    if (-not $sdks -or $sdks -match "No .NET SDKs were found") {
        $results.Add((Add-Result -Component "dotnet SDK" -Status "FAIL" -Detail "No .NET SDKs were found"))
    } else {
        $firstSdk = ($sdks -split "`r?`n")[0]
        $results.Add((Add-Result -Component "dotnet SDK" -Status "PASS" -Detail $firstSdk))
    }
}

$pnpModule = Get-Module -ListAvailable PnP.PowerShell | Sort-Object Version -Descending | Select-Object -First 1
$results.Add((Add-Result -Component "PnP.PowerShell" -Status ($(if($pnpModule){"PASS"}else{"WARNING"})) -Detail $(if($pnpModule){$pnpModule.Version.ToString()}else{"Not installed"})))

$graphModule = Get-Module -ListAvailable Microsoft.Graph | Sort-Object Version -Descending | Select-Object -First 1
$results.Add((Add-Result -Component "Microsoft.Graph" -Status ($(if($graphModule){"PASS"}else{"WARNING"})) -Detail $(if($graphModule){$graphModule.Version.ToString()}else{"Not installed"})))

$m365 = Get-CommandOutput -Name "m365" -Args @("version")
$results.Add((Add-Result -Component "CLI for Microsoft 365" -Status ($(if($m365.Found){"PASS"}else{"WARNING"})) -Detail $m365.Output))

$mcp = Get-Command pnp-powershell-mcp-server -ErrorAction SilentlyContinue
$results.Add((Add-Result -Component "PnP PowerShell MCP Server" -Status ($(if($mcp){"PASS"}else{"WARNING"})) -Detail $(if($mcp){"Command available"}else{"Not installed"})))

$mcpConfig = Test-Path ".vscode/mcp.json"
$results.Add((Add-Result -Component ".vscode/mcp.json" -Status ($(if($mcpConfig){"PASS"}else{"FAIL"})) -Detail $(if($mcpConfig){"Found"}else{"Missing"})))

$copilotInstructions = Test-Path ".github/copilot-instructions.md"
$results.Add((Add-Result -Component ".github/copilot-instructions.md" -Status ($(if($copilotInstructions){"PASS"}else{"FAIL"})) -Detail $(if($copilotInstructions){"Found"}else{"Missing"})))

$results | Format-Table -AutoSize

# Copilot Instructions for M365 AI Automation Toolkit

## Technology Preference
- For SharePoint Online, prefer PnP PowerShell first.
- For Microsoft Graph workloads, prefer Microsoft Graph PowerShell SDK.
- Use CLI for Microsoft 365 when it is simpler or better-supported.
- Use raw REST APIs only when no supported cmdlet or CLI command is available.

## PowerShell Standards
- Use PowerShell 7+.
- Prefer scripts with `[CmdletBinding()]` and `param()`.
- Use `Set-StrictMode -Version Latest` and `$ErrorActionPreference = "Stop"` where appropriate.
- Use approved PowerShell verbs, parameter validation, reusable functions, and try/catch/finally.
- Use meaningful error messages, structured logging, verbose output, and pipeline-friendly design.
- Use splatting when many parameters are required.
- Avoid unnecessary global variables.

## Authentication Standards
- Never hardcode passwords, tokens, client secrets, certificate passwords, or application secrets.
- For production automation prefer Managed Identity, certificate authentication, workload identity, or app-only authentication.
- Use interactive authentication primarily for local development.

## Microsoft Graph Standards
- Verify Graph cmdlet names and parameters.
- Identify required permissions and apply least privilege.
- Distinguish Delegated and Application permissions.
- Handle pagination, throttling, retries, null values, and large tenant scenarios.
- Do not request broad permissions when narrower permissions are sufficient.

## SharePoint Standards
- Prefer `Connect-PnPOnline` for SharePoint Online operations.
- Use modern authentication.
- Consider list thresholds, paging, CAML, batching, throttling, site collection scale, and large tenant performance.
- Prefer batching when it materially reduces API calls.

## Script Design Standards
- Build reusable scripts with parameterized inputs.
- Avoid hardcoded tenant URLs or fixed resource values.
- For impactful operations, support `-WhatIf` where feasible.

## Destructive Operation Protection
Never automatically execute commands involving:
- `Remove-*`, `Delete`, `Purge`, `Reset`, `Revoke`
- Tenant-wide configuration changes
- Permission removal
- Sharing changes
- User/group/team/site/mailbox deletion

Before any such operation, always provide:
1. The proposed command
2. What it will change
3. Potential impact
4. Affected resources

Then wait for explicit human approval.

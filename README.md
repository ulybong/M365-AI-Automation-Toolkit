# M365 AI Automation Toolkit

![License](https://img.shields.io/badge/license-MIT-green)

This repository is a reusable AI-assisted Microsoft 365 automation workspace for local development in VS Code with GitHub Copilot.

## Overview
Use this toolkit to build safe, repeatable Microsoft 365 automation scripts with PowerShell, Microsoft Graph, PnP PowerShell, and CLI for Microsoft 365.

This phase configures local tooling only. Authentication and Entra application configuration are handled separately.

## Getting Started

### Initial Setup (One-Time)

1. **Verify Prerequisites**
   ```powershell
   .\scripts\Utilities\Test-M365DevEnvironment.ps1
   ```
   Ensure all components show PASS or WARNING (not FAIL).

2. **Complete Missing Dependencies**
   - Install Git: https://git-scm.com/download/win
   - Install .NET SDK: https://aka.ms/dotnet/download (v8.0 or later)
   - After .NET SDK installation, open a new terminal and run:
     ```powershell
     dotnet tool install --global PnP.PowerShell.MCPServer --prerelease
     ```

3. **Reload VS Code**
   - Close and reopen the VS Code workspace to activate MCP servers
   - Verify MCP status in VS Code output panel

### Daily Workflow

1. **Open the workspace**
   ```powershell
   code C:\Project\M365-AI-Automation-Toolkit
   ```

2. **Use GitHub Copilot for script generation**
   - Open a new PowerShell file in VS Code
   - Use natural language prompts to describe what you need
   - Copilot will suggest code based on `.github/copilot-instructions.md` standards

3. **Test locally before running**
   ```powershell
   # Run with -WhatIf to preview changes
   .\scripts\SharePoint\Your-Script.ps1 -WhatIf
   ```

## Architecture
The toolkit is organized by workload-focused script folders and shared configuration, with MCP server definitions for AI-assisted command generation and automation guidance.

## Requirements
- Windows with PowerShell 7.4+
- VS Code
- Node.js and npm
- .NET SDK (required for .NET global tools such as PnP PowerShell MCP Server)
- Internet access for installing modules and npm packages

## PowerShell Modules
- `PnP.PowerShell` for SharePoint Online and Microsoft 365 admin automation patterns
- `Microsoft.Graph` for Microsoft Graph workloads

## MCP Servers
Configured in `.vscode/mcp.json`:
- PnP PowerShell MCP Server (read-only mode enabled)
- CLI for Microsoft 365 MCP Server

## GitHub Copilot
Repository guidance lives in `.github/copilot-instructions.md` and enforces secure automation standards, safe command behavior, and technology preference order.

## Folder Structure
- `.github/` repository guidance for Copilot
- `.vscode/` workspace settings, extension recommendations, MCP config
- `scripts/` workload-specific automation scripts
- `modules/` reusable local modules
- `config/examples/` sample configuration templates
- `docs/` supporting documentation
- `tests/` test scripts and validation helpers
- `output/` generated output artifacts
- `logs/` local logs

## Authentication
Authentication is intentionally not configured in this phase.

A later phase should define:
- Account model (delegated vs app-only)
- Entra app registrations
- Permission scopes and consent process
- Managed identity or certificate strategy for production

## Security
- No credentials or tokens should be committed.
- Secret-like files are excluded in `.gitignore`.
- MCP is configured in read-only mode for PnP PowerShell server.
- Destructive commands require explicit human approval before execution.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for code style, testing, and pull request guidance.

## Community

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community expectations.
See [SECURITY.md](SECURITY.md) for security reporting guidance.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Creating Scripts
Use reusable PowerShell patterns:
- `[CmdletBinding()]` + `param()`
- Input validation attributes
- `Set-StrictMode -Version Latest` and `$ErrorActionPreference = "Stop"` where appropriate
- `try/catch/finally`
- Support `-WhatIf` for impactful operations when feasible

## Testing
Run local environment validation:

```powershell
.\scripts\Utilities\Test-M365DevEnvironment.ps1
```

This test is local-only and does not authenticate to Microsoft 365.

## Troubleshooting
- If `dotnet tool` commands fail, install a .NET SDK (runtime-only installations are insufficient).
- If `m365` is not found after npm install, restart terminal or ensure npm global bin path is in `PATH`.
- If MCP servers do not appear in VS Code, reload the window after opening this workspace.

# Recon-Tools

Security recon and audit tooling for Windows, Active Directory, and Azure environments.

## Layout

- **`batch/`** Batch scripts (`.bat`) for quick on-host inventory and reconnaissance
- **`powershell/`** PowerShell scripts (`.ps1`) for deeper enumeration, structured output, and audit reports
- **`kql/`** KQL queries for Defender XDR / Sentinel hunting and analytics

## Scripts

### Batch

| Script | Purpose |
|--------|---------|
| `Find-Shares.bat` | Enumerates SMB shares across a subnet |
| `Get-ServiceList.bat` | Dumps all services and binary paths to a file |

### PowerShell

| Script | Purpose |
|--------|---------|
| _(coming soon)_ | |

### KQL

| Query | Purpose |
|-------|---------|
| _(coming soon)_ | |

## Notes

- Most scripts produce a `.txt` or `.csv` output file in the working directory.
- Output files are gitignored  don't commit findings to the repo.
- Run from a workstation with appropriate network access (some scripts assume SMB/RPC reachability to targets).
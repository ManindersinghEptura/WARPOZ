# Apollo Log Extraction - Complete Workflow Guide

## Quick Start Checklist

### For New CM Tickets Requiring Apollo Logs:

1. **[ ] Load Environment Variables**
   - Press `Ctrl+P` → Search "OnSite-CloudOps-Config" → Click to load

2. **[ ] Determine Timeframe**
   - Convert customer timezone to UTC
   - Add ±1 hour buffer for context

3. **[ ] Extract Logs**
   - Run: `.\quick-extract.ps1 -Environment "otago-uat" -Hours "20,21"`
   - Or use full script for advanced options

4. **[ ] Attach to Jira**
   - Add all extracted `.log` files to ticket
   - Include timezone clarification in comments

## Detailed Workflow Examples

### Example 1: CM-104053 Recreation
**Ticket**: "Retrieve Apollo Logs For 3/11/2026 US / 3/12 NZT"
**Request**: 2pm-4pm 3/11/2026 MDT | 9am-11am 3/12/2026 NZT

**Steps**:
```powershell
# 1. Load environment variables (Ctrl+P → OnSite-CloudOps-Config)

# 2. Convert timezone: 2pm-4pm MDT = 20:00-22:00 UTC (March 11)

# 3. Extract logs with buffer
.\quick-extract.ps1 -Environment "otago-uat" -Date "2026-03-11" -Hours "19,20,21,22,23"

# 4. Files created:
# - onsite-apollo-error-2026-03-11-19.log  (buffer)
# - onsite-apollo-error-2026-03-11-20.log  ✓ requested
# - onsite-apollo-error-2026-03-11-21.log  ✓ requested  
# - onsite-apollo-error-2026-03-11-22.log  (buffer)
# - onsite-apollo-error-2026-03-11-23.log  (buffer)
```

### Example 2: Staging Environment Issue
**Ticket**: "Apollo errors in staging during deployment"
**Request**: Last 2 hours of logs

**Steps**:
```powershell
# 1. Load environment variables
# 2. Calculate current UTC time minus 2 hours
$currentHour = (Get-Date).ToUniversalTime().Hour
$hours = @(($currentHour-2), ($currentHour-1), $currentHour)

# 3. Extract logs
.\quick-extract.ps1 -Environment "staging" -Hours ($hours -join ",")
```

### Example 3: Production Investigation
**Ticket**: "Customer reports mobile app crashes at 9am EST"
**Request**: Production logs around 9am EST = 14:00 UTC

**Steps**:
```powershell
# 1. Load environment variables
# 2. Extract production logs with buffer
.\quick-extract.ps1 -Environment "production" -Hours "13,14,15"
```

## Advanced Usage

### Full Featured Script
```powershell
.\scripts\extract-apollo-logs.ps1 `
  -Environment "otago-uat" `
  -Date "2026-03-11" `
  -Hours @("20", "21") `
  -LogType "both" `
  -OutputDir ".\CM-104053-logs"
```

### Parameters Explained
- **Environment**: `otago-uat`, `staging`, `production`, `apollo-east`
- **Date**: YYYY-MM-DD format (defaults to today)
- **Hours**: Array or comma-separated string of UTC hours
- **LogType**: `error` (default), `application`, `both`
- **OutputDir**: Custom directory for extracted logs

### Multiple Environments
```powershell
# Extract from both UAT and production
foreach ($env in @("otago-uat", "production")) {
    .\quick-extract.ps1 -Environment $env -Hours "14,15,16"
}
```

## Common Timezone Conversions

| Customer Location | Local Time | UTC Conversion | Command Hours |
|------------------|------------|----------------|---------------|
| US Eastern | 2pm-4pm EST | 19:00-21:00 UTC | "19,20,21" |
| US Mountain | 2pm-4pm MDT | 20:00-22:00 UTC | "20,21,22" |
| US Pacific | 2pm-4pm PDT | 21:00-23:00 UTC | "21,22,23" |
| New Zealand | 9am-11am NZDT | 20:00-22:00 UTC (prev day) | "20,21,22" |
| Australia | 2pm-4pm AEDT | 03:00-05:00 UTC | "03,04,05" |

## Error Handling

### Environment Variables Not Loaded
```
❌ OnSite environment variables not loaded!
Missing variables: AWS_PROFILE, EKS_CLUSTER_WEST

🚀 To fix this:
1. Press Ctrl+P (Command Palette)  
2. Search for: OnSite-CloudOps-Config
3. Click to load environment variables
4. Re-run this script
```

### No Logs Found for Date
```
⚠️ No logs found for 2026-03-11
```
**Resolution**: Check if date format is correct (YYYY-MM-DD) or try adjacent dates

### Pod Not Accessible
```
❌ No Apollo pods found in namespace: otago-uat
```
**Resolution**: Check environment name, verify AWS authentication, try other environment

### AWS Authentication Failed
```
❌ AWS authentication failed
Run: aws sso login --profile AdministratorAccess-946135482630
```

## Jira Ticket Best Practices

### Comment Template
```
Apollo logs extracted for [ENVIRONMENT] environment covering [TIMEFRAME].

Timeframe: [LOCAL TIME] = [UTC TIME]  
Files attached:
- onsite-apollo-error-YYYY-MM-DD-HH.log (X KB)
- onsite-apollo-error-YYYY-MM-DD-HH.log (X KB)

Notes:
- Logs are in UTC timezone
- Includes ±1 hour buffer for context
- [Any specific errors or patterns observed]
```

### File Naming Convention
- Keep original format: `onsite-apollo-error-YYYY-MM-DD-HH.log`
- Don't rename files - preserves timestamp correlation
- If multiple extractions, use folders: `CM-XXXXX-logs/`

## Performance Tips

### Batch Processing
```powershell
# Extract multiple hours at once rather than individual commands
.\quick-extract.ps1 -Environment "otago-uat" -Hours "14,15,16,17,18"
```

### Parallel Environments
```powershell
# Use PowerShell jobs for multiple environments
$jobs = @()
foreach ($env in @("otago-uat", "staging")) {
    $jobs += Start-Job -ScriptBlock { 
        .\quick-extract.ps1 -Environment $using:env -Hours "20,21" 
    }
}
$jobs | Wait-Job | Receive-Job
```

## Directory Structure Reference

```
apollo-logs-skill/
├── SKILL.md                    # Main skill documentation
├── quick-extract.ps1          # Simple workflow script  
├── scripts/
│   └── extract-apollo-logs.ps1  # Full-featured extraction
├── references/
│   ├── config-reference.md      # Environment variables & config
│   ├── workflow-guide.md        # This file - complete workflows
│   └── OnSite-CloudOps-Reference.md  # Full OnSite documentation
└── [output logs]/             # Generated log files
```
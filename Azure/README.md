# Azure Archibus VM Management with Warp

This directory contains pre-configured tools for instant Azure VM analysis and connection using Warp.

## 🚀 Quick Start

### 1. Load the Functions (One-time setup)
```powershell
# Navigate to the Azure directory
cd D:\Archibus\KT\Warp\WARPOZ\Azure

# Load the Azure VM functions
. .\azure-vm-functions.ps1
```

### 2. Connect to Azure
```powershell
# Connect to Eptura Archibus tenant
Connect-AzureArchibus
# or use alias:
archibus-connect
```

### 3. Instant VM Status
```powershell
# List all VMs and their status
Get-ArchibusVMs
# or use alias:
archibus-vms
```

## 🔧 Available Commands

### Connection & Management
```powershell
# Connect to VM via SSH (when network allows)
Connect-ArchibusVM -VMName "shinryo_uat_webcentral_0"

# Execute commands remotely (always works)
Invoke-ArchibusVMCommand -VMName "shinryo_uat_webcentral_0" -Command "systemctl status tomcat10"
```

### Monitoring & Logs
```powershell
# Get comprehensive system status
Get-ArchibusStatus -VMName "shinryo_uat_webcentral_0"

# Fetch application logs (default: 100 lines)
Get-ArchibusLogs -VMName "shinryo_uat_webcentral_0"

# Fetch more logs
Get-ArchibusLogs -VMName "shinryo_uat_webcentral_0" -Lines 1000
```

### Service Management
```powershell
# Restart Archibus Tomcat service
Restart-ArchibusService -VMName "shinryo_uat_webcentral_0"
```

### Help
```powershell
# Show all available commands
Get-ArchibusHelp
# or use alias:
archibus-help
```

## 📁 File Structure

```
D:\Archibus\KT\Warp\WARPOZ\Azure\
├── azure-vm-config.json           # VM configurations and credentials
├── azure-vm-functions.ps1         # PowerShell functions for VM management
├── README.md                       # This file
├── warp-profile.ps1               # Auto-load profile for Warp
└── Instance_Operations_Summary*.md # Historical operation documentation
```

## 🏗️ Configuration

The `azure-vm-config.json` file contains:
- **Tenant information**: Eptura Archibus tenant ID
- **VM details**: Resource groups, regions, purposes
- **Service paths**: Tomcat configurations, log paths
- **Monitoring info**: Cron logs, sync targets

### Adding New VMs
Edit `azure-vm-config.json` to add new VMs:
```json
"new_vm_name": {
    "resource_group": "RESOURCE-GROUP-NAME",
    "tenant": "eptura-archibus",
    "subscription": "archibus-prod",
    "region": "Japan East",
    "purpose": "Description of VM purpose",
    "services": {
        "tomcat10": {
            "service_name": "tomcat10",
            "config_path": "/opt/tomcat10/webapps/archibus/WEB-INF/config/",
            "log_path": "/opt/tomcat10/webapps/archibus/WEB-INF/config/archibus.log",
            "restart_script": "/opt/tomcat10/bin/restart_tomcat.sh"
        }
    }
}
```

## ⚡ Instant Analysis Examples

### Check VM Health
```powershell
Get-ArchibusStatus -VMName "shinryo_uat_webcentral_0"
```

### Monitor Application Activity
```powershell
# Check recent logs for errors
Get-ArchibusLogs -VMName "shinryo_uat_webcentral_0" -Lines 500

# Monitor real-time (via remote command)
Invoke-ArchibusVMCommand -VMName "shinryo_uat_webcentral_0" -Command "tail -f /opt/tomcat10/webapps/archibus/WEB-INF/config/archibus.log"
```

### Troubleshoot Connectivity Issues
```powershell
Invoke-ArchibusVMCommand -VMName "shinryo_uat_webcentral_0" -Command @"
echo '=== Network Connectivity ==='
netstat -tunlp | grep :8080
echo -e '\n=== Mount Status ==='
df -h | grep efs
echo -e '\n=== Service Status ==='
systemctl status tomcat10 --no-pager
"@
```

## 🔄 Auto-Setup for Warp Sessions

### Option 1: Add to PowerShell Profile
Add this line to your PowerShell profile (`$PROFILE`):
```powershell
# Load Azure VM functions if in the right directory
if (Test-Path "D:\Archibus\KT\Warp\WARPOZ\Azure\azure-vm-functions.ps1") {
    . "D:\Archibus\KT\Warp\WARPOZ\Azure\azure-vm-functions.ps1"
}
```

### Option 2: Quick Load Command
Create a quick command in your shell:
```powershell
# Add to your aliases or functions
function Load-ArchibusTools {
    Set-Location "D:\Archibus\KT\Warp\WARPOZ\Azure"
    . .\azure-vm-functions.ps1
    archibus-help
}
```

## 🛡️ Security Notes

- **Credentials**: Azure CLI handles authentication via `az login`
- **Access**: Uses your Azure AD permissions
- **Network**: SSH requires proper network security group configuration
- **Fallback**: `az vm run-command` works even when SSH is blocked

## 📊 Common Use Cases

1. **Daily Health Check**:
   ```powershell
   archibus-vms
   Get-ArchibusStatus -VMName "shinryo_uat_webcentral_0"
   ```

2. **Log Analysis**:
   ```powershell
   Get-ArchibusLogs -VMName "shinryo_uat_webcentral_0" -Lines 1000 | Out-File -FilePath "archibus-logs-$(Get-Date -Format 'yyyy-MM-dd').txt"
   ```

3. **Service Restart**:
   ```powershell
   Restart-ArchibusService -VMName "shinryo_uat_webcentral_0"
   Start-Sleep 30
   Get-ArchibusStatus -VMName "shinryo_uat_webcentral_0"
   ```

4. **Cron Job Monitoring**:
   ```powershell
   Invoke-ArchibusVMCommand -VMName "shinryo_uat_webcentral_0" -Command "crontab -l && echo -e '\n=== Watch Changes Log ===' && tail -50 /var/log/watch_changes.log"
   ```

## 🆘 Troubleshooting

- **SSH Timeout**: Use `Invoke-ArchibusVMCommand` instead of `Connect-ArchibusVM`
- **Authentication**: Run `az login --tenant 10b4d43b-4965-499a-89eb-b75b73b50d31` if commands fail
- **Permissions**: Ensure your Azure account has VM Contributor role
- **Network**: Check NSG rules if SSH connections fail

---

**Last Updated**: March 27, 2026  
**Maintainer**: CloudOps Team
# Azure VM Management Functions for Warp
# Source this file: . .\azure-vm-functions.ps1

# Load configuration
$ConfigPath = "$PSScriptRoot\azure-vm-config.json"
$Config = Get-Content $ConfigPath | ConvertFrom-Json

function Connect-AzureArchibus {
    <#
    .SYNOPSIS
    Connect to Eptura Archibus Azure tenant
    #>
    $TenantId = $Config.tenants.'eptura-archibus'.tenant_id
    Write-Host "🔐 Connecting to Eptura Archibus tenant: $TenantId" -ForegroundColor Yellow
    az login --tenant $TenantId
}

function Get-ArchibusVMs {
    <#
    .SYNOPSIS
    List all Archibus VMs with their status
    #>
    Write-Host "🖥️ Fetching Archibus VM status..." -ForegroundColor Yellow
    
    foreach ($vmName in $Config.vms.PSObject.Properties.Name) {
        $vm = $Config.vms.$vmName
        Write-Host "`n📍 VM: $vmName" -ForegroundColor Cyan
        
        $status = az vm show --resource-group $vm.resource_group --name $vmName --show-details --query "{PowerState:powerState, PrivateIp:privateIps, PublicIp:publicIps}" --output json | ConvertFrom-Json
        
        Write-Host "   Status: $($status.PowerState)" -ForegroundColor $(if($status.PowerState -eq 'VM running') {'Green'} else {'Red'})
        Write-Host "   Resource Group: $($vm.resource_group)" -ForegroundColor Gray
        Write-Host "   Region: $($vm.region)" -ForegroundColor Gray
        Write-Host "   Purpose: $($vm.purpose)" -ForegroundColor Gray
    }
}

function Connect-ArchibusVM {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName
    )
    <#
    .SYNOPSIS
    SSH connect to an Archibus VM
    #>
    if (-not $Config.vms.$VMName) {
        Write-Host "❌ VM '$VMName' not found in configuration" -ForegroundColor Red
        return
    }
    
    $vm = $Config.vms.$VMName
    Write-Host "🔗 Connecting to $VMName..." -ForegroundColor Yellow
    
    try {
        az ssh vm --resource-group $vm.resource_group --name $VMName
    } catch {
        Write-Host "⚠️ SSH failed, trying run-command approach..." -ForegroundColor Yellow
        Write-Host "Use: Invoke-ArchibusVMCommand -VMName '$VMName' -Command 'your_command'" -ForegroundColor Cyan
    }
}

function Invoke-ArchibusVMCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    <#
    .SYNOPSIS
    Execute command on Archibus VM remotely
    #>
    if (-not $Config.vms.$VMName) {
        Write-Host "❌ VM '$VMName' not found in configuration" -ForegroundColor Red
        return
    }
    
    $vm = $Config.vms.$VMName
    Write-Host "⚡ Executing on $VMName`: $Command" -ForegroundColor Yellow
    
    az vm run-command invoke --resource-group $vm.resource_group --name $VMName --command-id RunShellScript --scripts $Command
}

function Get-ArchibusLogs {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [int]$Lines = 100
    )
    <#
    .SYNOPSIS
    Fetch Archibus application logs
    #>
    if (-not $Config.vms.$VMName) {
        Write-Host "❌ VM '$VMName' not found in configuration" -ForegroundColor Red
        return
    }
    
    $vm = $Config.vms.$VMName
    $logPath = $vm.services.tomcat10.log_path
    
    Write-Host "📋 Fetching last $Lines lines from $VMName Archibus logs..." -ForegroundColor Yellow
    Invoke-ArchibusVMCommand -VMName $VMName -Command "tail -$Lines $logPath"
}

function Get-ArchibusStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName
    )
    <#
    .SYNOPSIS
    Get comprehensive Archibus service status
    #>
    if (-not $Config.vms.$VMName) {
        Write-Host "❌ VM '$VMName' not found in configuration" -ForegroundColor Red
        return
    }
    
    $vm = $Config.vms.$VMName
    $serviceName = $vm.services.tomcat10.service_name
    
    Write-Host "🔍 Checking $VMName Archibus status..." -ForegroundColor Yellow
    
    $statusCommand = @"
echo '=== SYSTEM STATUS ==='
uptime
free -h
df -h

echo -e '\n=== TOMCAT STATUS ==='
systemctl status $serviceName --no-pager

echo -e '\n=== RECENT LOGS (Last 20 lines) ==='
tail -20 $($vm.services.tomcat10.log_path)

echo -e '\n=== ACTIVE CONNECTIONS ==='
netstat -tunlp | grep java

echo -e '\n=== CRON JOBS ==='
crontab -l
"@

    Invoke-ArchibusVMCommand -VMName $VMName -Command $statusCommand
}

function Restart-ArchibusService {
    param(
        [Parameter(Mandatory=$true)]
        [string]$VMName
    )
    <#
    .SYNOPSIS
    Restart Archibus Tomcat service
    #>
    if (-not $Config.vms.$VMName) {
        Write-Host "❌ VM '$VMName' not found in configuration" -ForegroundColor Red
        return
    }
    
    $vm = $Config.vms.$VMName
    $restartScript = $vm.services.tomcat10.restart_script
    
    Write-Host "🔄 Restarting Archibus service on $VMName..." -ForegroundColor Yellow
    Invoke-ArchibusVMCommand -VMName $VMName -Command $restartScript
}

function Get-ArchibusHelp {
    <#
    .SYNOPSIS
    Display available Archibus VM management commands
    #>
    Write-Host @"
🔧 Archibus VM Management Commands:

📌 Connection & Setup:
   Connect-AzureArchibus          - Connect to Eptura Archibus tenant
   Get-ArchibusVMs               - List all VMs and their status

🖥️ VM Operations:
   Connect-ArchibusVM -VMName 'vm_name'              - SSH to VM
   Invoke-ArchibusVMCommand -VMName 'vm_name' -Command 'cmd'  - Run command remotely

📊 Monitoring:
   Get-ArchibusStatus -VMName 'vm_name'              - Comprehensive status check
   Get-ArchibusLogs -VMName 'vm_name' [-Lines 100]   - Fetch application logs

🛠️ Service Management:
   Restart-ArchibusService -VMName 'vm_name'         - Restart Tomcat service

Available VMs:
"@ -ForegroundColor Cyan

    foreach ($vmName in $Config.vms.PSObject.Properties.Name) {
        $vm = $Config.vms.$vmName
        Write-Host "   • $vmName - $($vm.purpose)" -ForegroundColor Yellow
    }
}

# Quick aliases
New-Alias -Name "archibus-connect" -Value Connect-AzureArchibus -Force
New-Alias -Name "archibus-vms" -Value Get-ArchibusVMs -Force
New-Alias -Name "archibus-help" -Value Get-ArchibusHelp -Force

Write-Host "✅ Azure VM functions loaded! Type 'archibus-help' for available commands." -ForegroundColor Green
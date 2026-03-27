# Warp Profile for Azure Archibus VM Management
# To use: Add this to your PowerShell profile or source manually

Write-Host "🚀 Initializing Azure Archibus Environment..." -ForegroundColor Blue

# Set location to Azure directory
$AzureDir = "D:\Archibus\KT\Warp\WARPOZ\Azure"
if (Test-Path $AzureDir) {
    Set-Location $AzureDir
    
    # Load Azure VM functions if available
    if (Test-Path ".\azure-vm-functions.ps1") {
        . .\azure-vm-functions.ps1
        Write-Host "✅ Azure VM functions loaded" -ForegroundColor Green
        
        # Auto-connect to Azure (optional - comment out if you don't want auto-connection)
        # Write-Host "🔐 Auto-connecting to Azure..." -ForegroundColor Yellow
        # Connect-AzureArchibus
    }
    
    Write-Host @"
🎯 Azure Archibus Environment Ready!

Quick Commands:
  archibus-help     - Show all available commands
  archibus-connect  - Connect to Azure tenant
  archibus-vms      - List VM status

Type any command to get started!
"@ -ForegroundColor Cyan
    
} else {
    Write-Host "❌ Azure directory not found: $AzureDir" -ForegroundColor Red
}

# Optional: Set up common aliases for this session
Set-Alias -Name "ll" -Value "Get-ChildItem" -Force -Scope Global
Set-Alias -Name "logs" -Value "Get-ArchibusLogs" -Force -Scope Global
Set-Alias -Name "status" -Value "Get-ArchibusStatus" -Force -Scope Global
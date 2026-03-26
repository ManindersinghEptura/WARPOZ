#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Quick Apollo log extraction workflow for Warp

.DESCRIPTION
    Simplified wrapper for Apollo log extraction that checks for environment variables
    and provides helpful guidance if they're not loaded.

.PARAMETER Environment
    Target environment (otago-uat, staging, production, apollo-east)

.PARAMETER Date
    Log date in YYYY-MM-DD format (defaults to today)

.PARAMETER Hours
    Comma-separated UTC hours to extract (e.g., "20,21")

.EXAMPLE
    .\quick-extract.ps1 -Environment "otago-uat" -Hours "20,21"
    
.EXAMPLE  
    .\quick-extract.ps1 -Environment "staging" -Date "2026-03-11" -Hours "14,15,16"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("otago-uat", "uat", "staging", "production")]
    [string]$Environment,
    
    [Parameter()]
    [string]$Date = (Get-Date -Format "yyyy-MM-dd"),
    
    [Parameter(Mandatory=$true)]
    [string]$Hours
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# Check if OnSite environment variables are loaded
$requiredVars = @("AWS_PROFILE", "EKS_CLUSTER_WEST", "EKS_REGION_WEST", "APOLLO_NAMESPACE_OTAGO")
$missingVars = @()

foreach ($var in $requiredVars) {
    if (-not (Get-Item "env:$var" -ErrorAction SilentlyContinue)) {
        $missingVars += $var
    }
}

if ($missingVars.Count -gt 0) {
    Write-ColorOutput "❌ OnSite environment variables not loaded!" "Red"
    Write-ColorOutput "Missing variables: $($missingVars -join ', ')" "Yellow"
    Write-ColorOutput ""
    Write-ColorOutput "🚀 To fix this:" "Cyan"
    Write-ColorOutput "1. Press Ctrl+P (Command Palette)" "White"
    Write-ColorOutput "2. Search for: OnSite-CloudOps-Config" "White"
    Write-ColorOutput "3. Click to load environment variables" "White"
    Write-ColorOutput "4. Re-run this script" "White"
    exit 1
}

Write-ColorOutput "✅ OnSite environment variables loaded" "Green"
Write-ColorOutput "AWS Account: $ENV:AWS_ACCOUNT" "Cyan"
Write-ColorOutput "Target Environment: $Environment" "Cyan"
Write-ColorOutput ""

# Convert hours string to array
$HoursArray = $Hours -split "," | ForEach-Object { $_.Trim() }

# Run the main extraction script
$scriptPath = Join-Path $PSScriptRoot "scripts\extract-apollo-logs.ps1"
& $scriptPath -Environment $Environment -Date $Date -Hours $HoursArray
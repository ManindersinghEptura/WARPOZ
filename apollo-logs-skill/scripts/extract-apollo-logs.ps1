#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Extract Apollo logs from EKS clusters for OnSite CloudOps troubleshooting

.DESCRIPTION
    Automates the process of retrieving Apollo/GraphQL logs from EKS clusters
    for troubleshooting customer issues. Handles authentication, pod discovery,
    and log extraction with proper error handling.

.PARAMETER Environment
    Target environment (otago-uat, staging, production, apollo-west)

.PARAMETER Date
    Log date in YYYY-MM-DD format

.PARAMETER Hours
    Array of UTC hours to extract (e.g., @("20", "21"))

.PARAMETER LogType
    Type of logs to extract: error, application, or both (default: error)

.PARAMETER OutputDir
    Directory to save extracted logs (default: current directory)

.EXAMPLE
    .\extract-apollo-logs.ps1 -Environment "otago-uat" -Date "2026-03-11" -Hours @("20", "21")
    
.EXAMPLE
    .\extract-apollo-logs.ps1 -Environment "staging" -Date "2026-03-12" -Hours @("14", "15", "16") -LogType "both"
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("otago-uat", "uat", "staging", "production")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
    [string]$Date,
    
    [Parameter(Mandatory=$true)]
    [string[]]$Hours,
    
    [Parameter()]
    [ValidateSet("error", "application", "both")]
    [string]$LogType = "error",
    
    [Parameter()]
    [string]$OutputDir = "."
)

# Environment configuration - uses Warp Drive environment variables
# Load OnSite-CloudOps-Config environment variables first!
$EnvironmentConfig = @{
    "otago-uat" = @{
        Cluster = $ENV:EKS_CLUSTER_EAST  # prod-apollo-cluster (us-east-2)
        Region = $ENV:EKS_REGION_EAST
        Namespace = $ENV:APOLLO_NAMESPACE_OTAGO  # otago-uat
        Profile = $ENV:AWS_PROFILE
    }
    "uat" = @{
        Cluster = "prod-apollo-cluster-west"  # General UAT (us-west-2)
        Region = "us-west-2"
        Namespace = "uat"
        Profile = $ENV:AWS_PROFILE
    }
    "staging" = @{
        Cluster = $ENV:EKS_CLUSTER_EAST  # prod-apollo-cluster (us-east-2)
        Region = $ENV:EKS_REGION_EAST
        Namespace = $ENV:APOLLO_NAMESPACE_STAGING  # staging
        Profile = $ENV:AWS_PROFILE
    }
    "production" = @{
        Cluster = $ENV:EKS_CLUSTER_EAST  # prod-apollo-cluster (us-east-2)
        Region = $ENV:EKS_REGION_EAST
        Namespace = $ENV:APOLLO_NAMESPACE_PROD  # prod
        Profile = $ENV:AWS_PROFILE
    }
}

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-AWSAuth {
    param([string]$Profile)
    
    Write-ColorOutput "🔐 Checking AWS authentication..." "Yellow"
    try {
        $identity = aws sts get-caller-identity --profile $Profile 2>$null | ConvertFrom-Json
        if ($identity.Account -eq "946135482630") {
            Write-ColorOutput "✅ AWS authentication verified" "Green"
            return $true
        }
    } catch {
        Write-ColorOutput "❌ AWS authentication failed" "Red"
        Write-ColorOutput "Run: aws sso login --profile $Profile" "Yellow"
        return $false
    }
    return $false
}

function Update-KubeConfig {
    param(
        [string]$Cluster,
        [string]$Region,
        [string]$Profile
    )
    
    Write-ColorOutput "🔧 Updating kubeconfig for cluster: $Cluster" "Yellow"
    try {
        aws eks update-kubeconfig --name $Cluster --region $Region --profile $Profile --output text
        Write-ColorOutput "✅ Kubeconfig updated successfully" "Green"
        return $true
    } catch {
        Write-ColorOutput "❌ Failed to update kubeconfig" "Red"
        return $false
    }
}

function Get-ApolloPods {
    param([string]$Namespace)
    
    Write-ColorOutput "🔍 Finding Apollo pods in namespace: $Namespace" "Yellow"
    try {
        $pods = kubectl get pods -n $Namespace -o name 2>$null | Where-Object { $_ -match "apollo" }
        if ($pods.Count -gt 0) {
            $podName = $pods[0] -replace "pod/", ""
            Write-ColorOutput "✅ Found Apollo pod: $podName" "Green"
            return $podName
        } else {
            Write-ColorOutput "❌ No Apollo pods found in namespace: $Namespace" "Red"
            return $null
        }
    } catch {
        Write-ColorOutput "❌ Failed to get pods" "Red"
        return $null
    }
}

function Get-AvailableLogs {
    param(
        [string]$PodName,
        [string]$Namespace,
        [string]$Date,
        [string]$LogType
    )
    
    Write-ColorOutput "📋 Checking available logs for $Date" "Yellow"
    try {
        $logPattern = if ($LogType -eq "both") { "onsite-apollo-.*-$Date" } else { "onsite-apollo-$LogType-$Date" }
        $availableLogs = kubectl exec -it $PodName -n $Namespace -- ls -la /app/logs/ 2>$null | Where-Object { $_ -match $logPattern }
        
        if ($availableLogs) {
            Write-ColorOutput "✅ Found logs for $Date" "Green"
            return $availableLogs
        } else {
            Write-ColorOutput "⚠️ No logs found for $Date" "Yellow"
            return $null
        }
    } catch {
        Write-ColorOutput "❌ Failed to list logs" "Red"
        return $null
    }
}

function Extract-LogFile {
    param(
        [string]$PodName,
        [string]$Namespace,
        [string]$LogPath,
        [string]$OutputPath
    )
    
    Write-ColorOutput "📥 Extracting: $LogPath" "Cyan"
    try {
        # Try compressed file first (.log.gz)
        $compressedPath = $LogPath
        $uncompressedPath = $LogPath -replace "\.gz$", ""
        
        # Check if compressed file exists
        $compressedExists = kubectl exec -it $PodName -n $Namespace -- test -f $compressedPath 2>$null
        if ($LASTEXITCODE -eq 0) {
            kubectl exec -it $PodName -n $Namespace -- zcat $compressedPath > $OutputPath 2>$null
        } else {
            # Try uncompressed file (.log)
            $uncompressedExists = kubectl exec -it $PodName -n $Namespace -- test -f $uncompressedPath 2>$null
            if ($LASTEXITCODE -eq 0) {
                kubectl exec -it $PodName -n $Namespace -- cat $uncompressedPath > $OutputPath 2>$null
            } else {
                Write-ColorOutput "❌ Neither compressed nor uncompressed file found: $LogPath" "Red"
                return $false
            }
        }
        
        if (Test-Path $OutputPath -and (Get-Item $OutputPath).Length -gt 0) {
            $size = [math]::Round((Get-Item $OutputPath).Length / 1KB, 2)
            Write-ColorOutput "✅ Extracted: $(Split-Path $OutputPath -Leaf) ($size KB)" "Green"
            return $true
        } else {
            Write-ColorOutput "⚠️ File extracted but empty: $(Split-Path $OutputPath -Leaf)" "Yellow"
            return $false
        }
    } catch {
        Write-ColorOutput "❌ Failed to extract: $LogPath" "Red"
        return $false
    }
}

function Main {
    Write-ColorOutput "🚀 Apollo Log Extraction Tool" "Cyan"
    Write-ColorOutput "Environment: $Environment" "White"
    Write-ColorOutput "Date: $Date" "White"
    Write-ColorOutput "Hours: $($Hours -join ', ')" "White"
    Write-ColorOutput "Log Type: $LogType" "White"
    Write-ColorOutput "" "White"
    
    $config = $EnvironmentConfig[$Environment]
    
    # Step 1: Verify AWS authentication
    if (-not (Test-AWSAuth -Profile $config.Profile)) {
        exit 1
    }
    
    # Step 2: Update kubeconfig
    if (-not (Update-KubeConfig -Cluster $config.Cluster -Region $config.Region -Profile $config.Profile)) {
        exit 1
    }
    
    # Step 3: Find Apollo pods
    $podName = Get-ApolloPods -Namespace $config.Namespace
    if (-not $podName) {
        exit 1
    }
    
    # Step 4: Check available logs
    $availableLogs = Get-AvailableLogs -PodName $podName -Namespace $config.Namespace -Date $Date -LogType $LogType
    
    # Step 5: Extract requested logs
    $extractedCount = 0
    $logTypes = if ($LogType -eq "both") { @("error", "application") } else { @($LogType) }
    
    foreach ($type in $logTypes) {
        foreach ($hour in $Hours) {
            $logFile = "onsite-apollo-$type-$Date-$hour.log.gz"
            $logPath = "/app/logs/$logFile"
            $outputFile = "$OutputDir/onsite-apollo-$type-$Date-$hour.log"
            
            if (Extract-LogFile -PodName $podName -Namespace $config.Namespace -LogPath $logPath -OutputPath $outputFile) {
                $extractedCount++
            }
        }
    }
    
    Write-ColorOutput "" "White"
    if ($extractedCount -gt 0) {
        Write-ColorOutput "🎉 Successfully extracted $extractedCount log files" "Green"
        Write-ColorOutput "📁 Output directory: $OutputDir" "Cyan"
    } else {
        Write-ColorOutput "⚠️ No logs were successfully extracted" "Yellow"
    }
}

# Execute main function
Main
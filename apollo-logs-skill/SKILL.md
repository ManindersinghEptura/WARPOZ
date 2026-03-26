---
name: apollo-logs-retrieval
description: Automated Apollo/GraphQL log retrieval from EKS clusters for OnSite CloudOps troubleshooting. Use when asked to retrieve Apollo logs, check GraphQL errors, investigate OnSite issues, extract logs from specific timeframes, troubleshoot customer errors in Apollo environments, or when working with Jira tickets requiring Apollo log analysis. Trigger phrases include "get Apollo logs", "retrieve logs", "check Apollo errors", "GraphQL logs", "OnSite logs", "extract logs from", environment names like "otago-uat", "staging", "production".
---

# Apollo Log Retrieval for OnSite CloudOps

Extract Apollo/GraphQL logs from EKS clusters for troubleshooting OnSite customer issues.

## Quick Start

**Step 1:** Load your OnSite configuration (one-time setup)
```powershell
# Load OnSite-CloudOps-Config environment variables from Warp Drive
# (Use Ctrl+P and search for "OnSite-CloudOps-Config" or click from Warp Drive)
```

**Step 2:** Extract Apollo logs
```powershell
# Set environment and timeframe
$Environment = "otago-uat"  # otago-uat, staging, production, apollo-east
$Date = "2026-03-11"        # YYYY-MM-DD format
$Hours = @("20", "21")      # UTC hours array

# Run extraction (uses your loaded environment variables)
./scripts/extract-apollo-logs.ps1 -Environment $Environment -Date $Date -Hours $Hours
```

## Supported Environments

Environments use your **OnSite-CloudOps-Config** Warp Drive environment variables:

| Environment | Cluster Variable | Region Variable | Namespace Variable |
|-------------|------------------|-----------------|--------------------|
| otago-uat | $ENV:EKS_CLUSTER_WEST | $ENV:EKS_REGION_WEST | $ENV:APOLLO_NAMESPACE_OTAGO |
| staging | $ENV:EKS_CLUSTER_WEST | $ENV:EKS_REGION_WEST | $ENV:APOLLO_NAMESPACE_STAGING |  
| production | $ENV:EKS_CLUSTER_WEST | $ENV:EKS_REGION_WEST | $ENV:APOLLO_NAMESPACE_PROD |
| apollo-east | $ENV:EKS_CLUSTER_EAST | $ENV:EKS_REGION_EAST | $ENV:APOLLO_NAMESPACE_PROD |

**Actual Values:** prod-apollo-cluster-west (us-west-2), otago-uat/staging/prod namespaces

## Timezone Reference

Common timezone conversions for log analysis:

- **UTC** (log timestamps) 
- **MDT** = UTC - 6 hours
- **EST** = UTC - 5 hours  
- **NZT** = UTC + 12/13 hours (depending on DST)

**Example**: 2pm-4pm MDT = 20:00-22:00 UTC

## Workflow

1. **Authenticate**: AWS SSO login with AdministratorAccess-946135482630 profile
2. **Configure**: Update kubeconfig for target cluster
3. **Identify**: Find running Apollo pods in target namespace
4. **Extract**: Retrieve compressed logs using kubectl + zcat
5. **Deliver**: Save logs locally with descriptive names

## Log File Patterns

Apollo logs are stored as: `/app/logs/onsite-apollo-{type}-YYYY-MM-DD-HH.log.gz`

Types:
- `error` - Error logs for troubleshooting
- `application` - General application logs

## Manual Commands Reference

```powershell
# 1. AWS Authentication
aws sts get-caller-identity --profile AdministratorAccess-946135482630

# 2. Update kubeconfig  
aws eks update-kubeconfig --name prod-apollo-cluster --region us-east-2 --profile AdministratorAccess-946135482630

# 3. Find pods
kubectl get pods -n otago-uat

# 4. List available logs
kubectl exec -it [POD-NAME] -n [NAMESPACE] -- ls -la /app/logs/ | Where-Object { $_ -match "2026-03-11" }

# 5. Extract logs
kubectl exec -it [POD-NAME] -n [NAMESPACE] -- zcat /app/logs/onsite-apollo-error-2026-03-11-20.log.gz > onsite-apollo-error-2026-03-11-20.log
```

## Jira Integration

When working with CM tickets requiring Apollo logs:

1. Extract logs covering requested timeframe + 1 hour buffer
2. Use descriptive filenames: `onsite-apollo-error-YYYY-MM-DD-HH.log`
3. Attach all relevant log files to Jira ticket
4. Include timezone clarification in comments
5. Mark ticket status appropriately after delivery

## Documentation Reference

This skill includes comprehensive documentation in the `references/` directory:

- **[config-reference.md](references/config-reference.md)** - Environment variables, mappings, and infrastructure details
- **[workflow-guide.md](references/workflow-guide.md)** - Complete workflow examples, timezone conversions, and Jira best practices  
- **[OnSite-CloudOps-Reference.md](references/OnSite-CloudOps-Reference.md)** - Full OnSite architecture and troubleshooting guide

## Quick References

### Environment Variables (Private)
Your `OnSite-CloudOps-Config` contains 9 variables including AWS profiles, cluster names, and namespaces.
**Load with**: `Ctrl+P` → Search "OnSite-CloudOps-Config"

### Common Timezone Conversions
- **MDT** = UTC - 6 hours (2pm MDT = 20:00 UTC)
- **EST** = UTC - 5 hours (3pm EST = 20:00 UTC)
- **NZT** = UTC + 12/13 hours (8am NZT = 20:00 UTC prev day)

### Key People
- **Apollo/Logs**: Alex Plotkin
- **WAR/Auth**: Dany Silva  
- **Infrastructure**: Santosh Prasad

## Troubleshooting

**Environment variables not loaded**: Use `Ctrl+P` → "OnSite-CloudOps-Config"
**Pod not found**: Check environment name, verify AWS authentication
**Permission denied**: Run `aws sso login --profile AdministratorAccess-946135482630`
**No logs found**: Check date format (YYYY-MM-DD) or try adjacent dates
**Connection timeout**: Verify cluster region and AWS profile

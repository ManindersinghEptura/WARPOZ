# Apollo Log Extraction - Configuration Reference

## Warp Drive Environment Variables

Your **OnSite-CloudOps-Config** personal environment variable contains:

```
AWS_PROFILE = AdministratorAccess-946135482630
AWS_ACCOUNT = 946135482630
EKS_CLUSTER_EAST = prod-apollo-cluster  
EKS_CLUSTER_WEST = prod-apollo-cluster-west
EKS_REGION_EAST = us-east-2
EKS_REGION_WEST = us-west-2
APOLLO_NAMESPACE_OTAGO = otago-uat
APOLLO_NAMESPACE_STAGING = staging
APOLLO_NAMESPACE_PROD = prod
```

**ID**: `alxFzDdilSiZwyl70jv4Vz`

## Environment Mappings

| Environment | Cluster Variable | Region Variable | Namespace Variable | Actual Values |
|-------------|------------------|-----------------|--------------------|--------------| 
| otago-uat | EKS_CLUSTER_WEST | EKS_REGION_WEST | APOLLO_NAMESPACE_OTAGO | prod-apollo-cluster-west, us-west-2, otago-uat |
| staging | EKS_CLUSTER_WEST | EKS_REGION_WEST | APOLLO_NAMESPACE_STAGING | prod-apollo-cluster-west, us-west-2, staging |
| production | EKS_CLUSTER_WEST | EKS_REGION_WEST | APOLLO_NAMESPACE_PROD | prod-apollo-cluster-west, us-west-2, prod |
| apollo-east | EKS_CLUSTER_EAST | EKS_REGION_EAST | APOLLO_NAMESPACE_PROD | prod-apollo-cluster, us-east-2, prod |

## Current Active Infrastructure

Based on your OnSite reference documentation:

- **Active Cluster**: prod-apollo-cluster-west (us-west-2) - serves ALL environments
- **Legacy Cluster**: prod-apollo-cluster (us-east-2) - unused but kept for reference
- **Primary Environment**: Otago UAT (`otago-uat` namespace)
- **Pod Naming Pattern**: `apollo-{env}-*` (e.g., `apollo-otago-uat-79545b5c95-pnsxr`)

## Key People & Responsibilities

| Task | Owner |
|------|-------|
| Apollo EKS deployment / upgrade | Alex Plotkin |
| WAR deployment to Node 3 | Dany Silva |
| EC2 / infrastructure config | Santosh Prasad |
| Log retrieval (SSM) | Alex Plotkin |
| Mobile app release / Allbound | Alex Plotkin |

## Apollo Health Check URLs

- **Otago UAT**: `https://apollo-otago-uat.archibus.cloud/`
- **Default UAT**: `https://apollo-uat.archibus.cloud/`
- **Production**: `https://apollo.archibus.cloud/`

### Health Check Command
```powershell
Invoke-RestMethod -Method POST -Uri "https://apollo-otago-uat.archibus.cloud/" `
  -ContentType "application/json" `
  -Body '{"query":"{ apolloSettings { contractVersion version webCentralVersion } }"}'
```

## Common Log Patterns

### Log File Locations (Inside Pods)
- **Path**: `/app/logs/`
- **Pattern**: `onsite-apollo-{type}-YYYY-MM-DD-HH.log.gz`
- **Types**: `error`, `application`

### Recent Example (CM-104053)
- **Date**: March 11, 2026
- **Timeframe**: 2pm-4pm MDT = 20:00-22:00 UTC
- **Files Retrieved**: 
  - `onsite-apollo-error-2026-03-11-20.log.gz`
  - `onsite-apollo-error-2026-03-11-21.log.gz` 
  - Plus surrounding hours for context

## Timezone Reference

| Timezone | UTC Offset | Example Conversion |
|----------|------------|-------------------|
| UTC | +0 | 20:00 UTC |
| MDT | -6 | 2pm MDT = 20:00 UTC |
| EST | -5 | 3pm EST = 20:00 UTC |
| NZT | +12/+13 | 8am NZT = 20:00 UTC (prev day) |

## Jira Integration

- **Project**: CM (Change Management)
- **MCP Server**: Jira-MCPServer
- **Common Labels**: OnSite, Apollo
- **Typical Format**: CM-XXXXXX
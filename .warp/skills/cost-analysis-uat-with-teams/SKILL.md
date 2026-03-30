---
name: cost-analysis-uat-teams
description: Monthly cost analysis for Archibus UAT subscription with automatic Teams notification. Tracks testing and staging costs, identifies anomalies, and posts results to Teams webhook.
---

# Azure Cost Analysis - UAT Subscription (with Teams Notification)

## Overview

This skill generates comprehensive monthly cost analysis reports for the **Archibus-UAT** Azure subscription (0fa1abc1-6f76-41d4-a7ea-dfe84932b544) and automatically sends results to Teams via webhook.

## When to Use

- Generate and automatically notify Teams of monthly UAT cost analysis
- Monitor testing and staging environment spending
- Post cost trends and anomalies to team channel
- Automated monthly cost reporting for UAT
- Track non-production workload expenses

## Prerequisites

This skill uses the Teams webhook URL you already created:

```bash
TEAMS_ARCHIBUS_WEBHOOK_URL  # Secret you created in production
```

**Note:** This skill reuses the same Teams webhook as PROD. Both PROD and UAT messages will post to the same Teams channel.

## Key Capabilities

### 1. Cost Breakdown Analysis
- Total costs for the current month
- Cost by resource type (Compute, Storage, Databases, Networking)
- Top 10 most expensive resources in UAT
- Cost per service comparison
- Resource count and utilization

### 2. Month-over-Month Comparison
- Compare current month vs. previous month
- Identify cost increases and decreases
- Calculate percentage changes
- Track UAT-specific trends

### 3. Cost Driver Identification
For UAT, the primary cost drivers are typically:
- **Recovery Services/Backups** (20-30%) - Test environment backups
- **Virtual Machines** (25-35%) - Test/staging instances
- **SQL Databases** (15-25%) - Test databases
- **Storage** (10-20%) - Test data and logs
- **Networking** (5-10%) - Test connectivity

### 4. Automatic Teams Notification
Results are posted to Teams as formatted Adaptive Card with:
- UAT cost summary and trends
- Anomaly detection and alerts
- Budget status and forecasting
- Optimization recommendations
- Action items for QA team

## How to Use

### Via Oz Web App (Recommended)
1. Go to https://oz.warp.dev/schedules
2. Click "New schedule"
3. **Name**: `Azure Cost Analysis - UAT with Teams`
4. **Agent**: Select `cost-analysis-uat-teams`
5. **Environment**: Select your WARPOZ environment
6. **Cron**: `0 9 2 * *` (2nd of month at 9 AM - runs after PROD)
7. **Create schedule**

Results automatically post to Teams every month on the 2nd at 9 AM!

### Via CLI
```bash
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "cost-analysis-uat-teams" \
  --prompt "Generate monthly UAT cost analysis and send to Teams"
```

### Manual Run (Testing)
```bash
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "cost-analysis-uat-teams" \
  --prompt "Run cost analysis for March UAT and notify Teams"
```

## Teams Webhook Setup

### Using Your Existing Secret

Verify your secret is set:

```bash
oz secret list | grep TEAMS_ARCHIBUS_WEBHOOK_URL
```

Both PROD and UAT skills use the same `TEAMS_ARCHIBUS_WEBHOOK_URL` secret, so both messages post to the same Teams channel.
3. Click **...** → **Connectors**
4. Search for **Incoming Webhook**
5. Click **Configure**
6. Name: `Azure UAT Cost Analysis Bot`
7. Click **Create**
8. Copy the webhook URL
9. Store as Oz secret: `oz secret create --team TEAMS_UAT_WEBHOOK_URL`

## Sample Teams Notification

When the skill runs, you'll see a formatted message in Teams:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 ARCHIBUS UAT - Monthly Cost Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💰 Total Cost: $769.90
📈 Month-over-Month: +$12.38 (+1.63%)
✅ Status: Stable (within budget)

📦 Cost by Resource Type:
  • Recovery Services: $180 (23%)
  • Virtual Machines: $250 (32%)
  • SQL Databases: $180 (23%)
  • Storage: $130 (17%)
  • Networking: $30 (5%)

🎯 Optimization Opportunities:
  • Auto-shutdown non-business hours: Save $100-150/month
  • Downsize test VMs to B-series: Save $50-100/month
  • Clean up old test data: Save $20-30/month

Budget Status: $769.90 / $1,000 (77% of budget)
Next Review: April 2nd at 9 AM
```

## Subscription Details

- **Name**: Archibus-UAT
- **Subscription ID**: 0fa1abc1-6f76-41d4-a7ea-dfe84932b544
- **Tenant ID**: 10b4d43b-4965-499a-89eb-b75b73b50d31
- **MCP Server**: azure-mcp-uat
- **Environment Type**: Testing and QA
- **Monthly Budget**: $1,000

## Environment Variables Required

```
TEAMS_ARCHIBUS_WEBHOOK_URL    (Oz secret - your Teams webhook)
AZURE_TENANT_ID               (Already configured)
AZURE_SUBSCRIPTION_ID          (Already configured)
```

## UAT Budget Guidelines

- **Current Monthly**: $769.90
- **Recommended Budget**: $1,000/month
- **Alert Threshold**: $1,200/month (+20% increase)
- **Action Required**: If costs exceed $1,500/month

## Troubleshooting

### Message Not Appearing in Teams

1. **Check webhook URL is correct**
   ```bash
   oz secret update --value TEAMS_ARCHIBUS_WEBHOOK_URL
   ```

2. **Verify Teams channel permissions**
   - Make sure webhook has permission to post

3. **Check Oz logs**
   - Go to https://oz.warp.dev/runs
   - Find your run and check logs for errors

### Cost Analysis Not Running

1. **Verify Azure credentials** - Check `.warp/.mcp.json`
2. **Verify MCP server** - Confirm `azure-mcp-uat` is accessible
3. **Check permissions** - Ensure UAT subscription access is valid

## Monthly Workflow

1. **PROD Report** - 1st of month at 9 AM (cost-analysis-prod-teams)
2. **UAT Report** - 2nd of month at 9 AM (cost-analysis-uat-teams)
3. **Team Review** - CloudOps reviews both reports in Teams
4. **Budget Check** - Verify UAT spending within limits
5. **Action Items** - Implement recommendations

## Cost Optimization Checklist for UAT

High Priority (Save 15-25%):
- [ ] Implement auto-shutdown for non-business hours
- [ ] Downsize test VMs to smaller SKUs (B-series)

Medium Priority (Save 10-15%):
- [ ] Reduce SQL database tiers for non-critical testing
- [ ] Clean up old storage and deleted resources

Low Priority (Save 5-10%):
- [ ] Consolidate multiple test storage accounts
- [ ] Review backup retention policies
- [ ] Use Spot instances for disposable test environments

## References

- **Azure Cost Management**: https://portal.azure.com
- **Teams Webhooks**: https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/incoming-webhooks
- **Auto-shutdown**: https://learn.microsoft.com/en-us/azure/labs/how-to-configure-auto-shutdown
- **Cost Optimization**: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/govern/cost-management/

## Related Skills

- `cost-analysis-uat` - UAT analysis (no Teams notification)
- `cost-analysis-prod-teams` - PROD analysis with Teams notification
- `cost-analysis-prod` - PROD analysis only
- `azure-cost-analysis` - Generic cost analysis

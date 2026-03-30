---
name: cost-analysis-prod-teams
description: Monthly cost analysis for Archibus PROD subscription with automatic Teams notification. Analyzes costs, identifies cost drivers, compares month-over-month trends, and posts results to Teams webhook.
---

# Azure Cost Analysis - PROD Subscription (with Teams Notification)

## Overview

This skill generates comprehensive monthly cost analysis reports for the **Archibus-PROD** Azure subscription (aaab7ee1-9ce0-453b-9599-efe6c15470af) and automatically sends results to Teams via webhook.

## When to Use

- Generate and automatically notify Teams of monthly PROD cost analysis
- Post cost increases and alerts to team channel
- Automated monthly cost reporting with zero-touch notification
- Track spending trends with team visibility

## Prerequisites

This skill requires a Teams webhook URL stored as an Oz secret:

```bash
oz secret create --team TEAMS_WEBHOOK_URL
# Paste your Teams webhook URL when prompted
```

Your Teams webhook: `https://eptura.webhook.office.com/webhookb2/...`

## Key Capabilities

### 1. Cost Breakdown Analysis
- Total costs for the current month
- Cost by resource type (Compute, Storage, Databases, Networking)
- Top 20 most expensive resources
- Cost per service comparison

### 2. Month-over-Month Comparison
- Compare current month vs. previous month
- Identify cost increases and decreases
- Calculate percentage changes
- Highlight resource-level changes

### 3. Cost Driver Identification
For PROD, the primary cost drivers are typically:
- **Virtual Machines** (30-50% of costs)
- **SQL Databases** (15-25%)
- **Application Gateways** (10-20%)
- **Storage** (10-20%)
- **Networking** (5-10%)

### 4. Automatic Teams Notification
Results are posted to Teams as formatted Adaptive Card with:
- Cost summary and trends
- Top cost drivers highlighted
- Optimization recommendations
- Visual charts and breakdowns
- Action items for CloudOps team

## How to Use

### Via Oz Web App (Recommended)
1. Go to https://oz.warp.dev/schedules
2. Click "New schedule"
3. **Name**: `Azure Cost Analysis - PROD with Teams`
4. **Agent**: Select `cost-analysis-prod-teams`
5. **Environment**: Select your WARPOZ environment
6. **Cron**: `0 9 1 * *` (1st of month at 9 AM)
7. **Create schedule**

Results automatically post to Teams every month on the 1st at 9 AM!

### Via CLI
```bash
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "cost-analysis-prod-teams" \
  --prompt "Generate monthly cost analysis and send to Teams"
```

### Manual Run (Testing)
```bash
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "cost-analysis-prod-teams" \
  --prompt "Run cost analysis for March and notify Teams"
```

## Teams Webhook Setup

### Step 1: Get Teams Webhook URL
1. Open Microsoft Teams
2. Go to your team's **CloudOps** channel
3. Click **...** (More options) → **Connectors**
4. Search for **Incoming Webhook**
5. Click **Configure**
6. Name: `Azure Cost Analysis Bot`
7. Click **Create**
8. Copy the webhook URL

### Step 2: Store in Oz Secrets
```bash
oz secret create --team TEAMS_WEBHOOK_URL
# Paste webhook URL when prompted
```

### Step 3: Verify It Works
Run the skill once manually to test:
```bash
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "cost-analysis-prod-teams" \
  --prompt "Test Teams webhook integration"
```

Check your Teams channel - you should see a message!

## Sample Teams Notification

When the skill runs, you'll see a formatted message in Teams like:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 ARCHIBUS PROD - Monthly Cost Analysis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💰 Total Cost: $6,720.54
📈 Month-over-Month: +$395.76 (+6.26%)

🔴 Top Cost Drivers:
  1. Virtual Machines: +$129 (33%)
  2. SQL Databases: +$91 (23%)
  3. App Gateways: +$69 (17%)
  4. Storage: +$56 (14%)
  5. Other: +$51 (13%)

🎯 Optimization Opportunities:
  • Right-size VMs: Save $100-200/month
  • Downgrade SQL tiers: Save $50-150/month
  • Clean up unused disks: Save $30-50/month

Report: [View Full Analysis]
```

## Subscription Details

- **Name**: Archibus-PROD
- **Subscription ID**: aaab7ee1-9ce0-453b-9599-efe6c15470af
- **Tenant ID**: 10b4d43b-4965-499a-89eb-b75b73b50d31
- **MCP Server**: azure-mcp-prod
- **Resource Count**: 483 resources

## Environment Variables Required

```
TEAMS_WEBHOOK_URL    (Oz secret - your Teams webhook)
AZURE_TENANT_ID      (Already configured)
AZURE_SUBSCRIPTION_ID (Already configured)
```

## Troubleshooting

### Message Not Appearing in Teams

1. **Check webhook URL is correct**
   ```bash
   oz secret update --value TEAMS_WEBHOOK_URL
   ```

2. **Verify Teams channel permissions**
   - Make sure webhook has permission to post to channel

3. **Check Oz logs**
   - Go to https://oz.warp.dev/runs
   - Find your run and check logs for errors

4. **Test webhook independently**
   ```powershell
   $webhook = "your-webhook-url"
   $body = @{ text = "Test message" } | ConvertTo-Json
   Invoke-RestMethod -Uri $webhook -Method Post -Body $body
   ```

### Cost Analysis Not Running

1. **Verify Azure credentials** - Check `.warp/.mcp.json`
2. **Verify MCP server** - Confirm `azure-mcp-prod` is accessible
3. **Check permissions** - Ensure subscription access is valid

## Monthly Workflow

1. **Automatic Trigger** - 1st of month at 9 AM
2. **Analysis** - Azure cost data queried and analyzed
3. **Teams Notification** - Results posted to Teams channel
4. **Team Review** - CloudOps team reviews findings in Teams
5. **Action Items** - Implement recommendations from report

## Cost Optimization Checklist

High Priority (Save 20-30%):
- [ ] Right-size oversized VMs
- [ ] Downgrade unused database tiers
- [ ] Delete unused storage/disks

Medium Priority (Save 10-20%):
- [ ] Use Reserved Instances
- [ ] Implement auto-shutdown
- [ ] Consolidate storage accounts

Low Priority (Save 5-10%):
- [ ] Use Spot instances
- [ ] Implement lifecycle policies
- [ ] Consolidate network resources

## References

- **Azure Cost Management**: https://portal.azure.com
- **Teams Webhooks**: https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/incoming-webhooks
- **Reserved Instances**: https://learn.microsoft.com/en-us/azure/virtual-machines/reserved-vms-overview
- **Cost Optimization**: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/govern/cost-management/

## Related Skills

- `cost-analysis-prod` - PROD analysis (no Teams notification)
- `cost-analysis-uat` - UAT analysis
- `azure-cost-analysis` - Generic cost analysis

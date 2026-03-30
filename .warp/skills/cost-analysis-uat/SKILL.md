---
name: cost-analysis-uat
description: Monthly cost analysis for Archibus UAT subscription. Tracks testing and staging costs, identifies anomalies, and provides optimization recommendations for non-production workloads.
---

# Azure Cost Analysis - UAT Subscription

## Overview

This skill generates comprehensive monthly cost analysis reports for the **Archibus-UAT** Azure subscription (0fa1abc1-6f76-41d4-a7ea-dfe84932b544).

## When to Use

- Generate monthly cost analysis for UAT subscription
- Monitor testing and staging environment costs
- Identify cost anomalies in UAT
- Get optimization recommendations for test workloads
- Track UAT spending trends month-over-month

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
- **Virtual Machines** (25-35%) - Test/staging instances (often smaller SKUs)
- **SQL Databases** (15-25%) - Test databases
- **Storage** (10-20%) - Test data, logs, artifacts
- **Networking** (5-10%) - Test connectivity, data transfer

### 4. UAT-Specific Optimization
- Auto-shutdown policies for non-business hours
- Downsize test instances (use B-series VMs instead of D-series)
- Reduce database tier to Standard instead of Premium for testing
- Clean up old test data and artifacts
- Consolidate storage for test environments

## How to Use

```
"Generate monthly cost analysis for UAT subscription"
"Show UAT cost trends"
"Which resources are most expensive in UAT?"
"Is UAT spending within budget?"
"Recommend cost optimizations for UAT testing"
```

## Subscription Details

- **Name**: Archibus-UAT
- **Subscription ID**: 0fa1abc1-6f76-41d4-a7ea-dfe84932b544
- **Tenant ID**: 10b4d43b-4965-499a-89eb-b75b73b50d31
- **MCP Server**: azure-mcp-uat
- **Environment Type**: Testing and QA
- **Expected Cost Range**: $500-1,000/month

## Key Insights from Recent Analysis

### March 2026 Costs
- **Total**: $769.90
- **Month-over-Month**: +$12.38 (+1.63% from February)
- **Status**: Stable ✓

### Spending Trend
- January: ~$755
- February: ~$757.52
- March: $769.90
- **Trend**: Consistent and stable

## Cost Optimization Opportunities

### High Priority (Save 15-25%)
- Implement auto-shutdown for non-business hours (potential savings: $100-150/month)
- Downsize test VMs to smaller SKUs (potential savings: $50-100/month)

### Medium Priority (Save 10-15%)
- Reduce SQL database tiers for non-critical testing (potential savings: $30-50/month)
- Clean up old storage and deleted resources (potential savings: $20-30/month)

### Low Priority (Save 5-10%)
- Consolidate multiple test storage accounts
- Review backup retention policies
- Use Spot instances for disposable test environments (70-90% discount)

## Monthly Workflow

1. **First business day of month** - Automatic cost analysis runs
2. **Verify stability** - Check if costs are within expected range
3. **Review anomalies** - Investigate any unexpected cost changes
4. **Maintain policies** - Ensure auto-shutdown and cleanup run regularly
5. **Plan testing** - Budget for upcoming test cycles

## Budget Guidelines

- **Current Monthly**: $769.90
- **Recommended Budget**: $1,000/month
- **Alert Threshold**: $1,200/month (+50% increase)
- **Action Required**: If costs exceed $1,500/month

## References

- **Azure Cost Management**: https://portal.azure.com (Cost Management + Billing)
- **Auto-shutdown**: https://learn.microsoft.com/en-us/azure/labs/how-to-configure-auto-shutdown
- **Right-sizing**: https://learn.microsoft.com/en-us/azure/advisor/advisor-cost-recommendations
- **Cost Optimization**: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/govern/cost-management/

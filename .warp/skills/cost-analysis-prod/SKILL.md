---
name: cost-analysis-prod
description: Monthly cost analysis for Archibus PROD subscription. Analyzes costs, identifies cost drivers, compares month-over-month trends, and provides optimization recommendations for production workloads.
---

# Azure Cost Analysis - PROD Subscription

## Overview

This skill generates comprehensive monthly cost analysis reports for the **Archibus-PROD** Azure subscription (aaab7ee1-9ce0-453b-9599-efe6c15470af).

## When to Use

- Generate monthly cost analysis for PROD subscription
- Identify cost increases and root causes
- Get optimization recommendations for production workloads
- Track spending trends month-over-month
- Review resource utilization and costs

## Key Capabilities

### 1. Cost Breakdown Analysis
- Total costs for the current month
- Cost by resource type (Compute, Storage, Databases, Networking, etc.)
- Top 20 most expensive resources
- Cost per service comparison

### 2. Month-over-Month Comparison
- Compare current month vs. previous month
- Identify cost increases and decreases
- Calculate percentage changes
- Highlight resource-level changes

### 3. Cost Driver Identification
For PROD, the primary cost drivers are typically:
- **Virtual Machines** (30-50% of costs) - Production workloads, always-on instances
- **SQL Databases** (15-25%) - Production data stores with high availability tiers
- **Application Gateways** (10-20%) - Load balancing for production traffic
- **Storage** (10-20%) - Data persistence, backups, archives
- **Networking** (5-10%) - Data transfer, connectivity

### 4. Production-Specific Optimization
- Right-sizing opportunities (oversized VMs, over-provisioned databases)
- Reserved Instances for predictable production workloads (30-50% savings)
- Auto-shutdown policies for non-production workloads within PROD
- Backup and storage optimization
- Network cost reduction strategies

## How to Use

```
"Generate monthly cost analysis for PROD subscription"
"Analyze why PROD costs increased this month"
"Show cost breakdown for PROD resources"
"Which resources are most expensive in PROD?"
"Recommend cost optimizations for PROD"
```

## Subscription Details

- **Name**: Archibus-PROD
- **Subscription ID**: aaab7ee1-9ce0-453b-9599-efe6c15470af
- **Tenant ID**: 10b4d43b-4965-499a-89eb-b75b73b50d31
- **MCP Server**: azure-mcp-prod
- **Resource Count**: 483 resources (32 VMs, 23 SQL databases, 28 storage accounts, 7 app gateways)

## Key Insights from Recent Analysis

### March 2026 Costs
- **Total**: $6,720.54
- **Month-over-Month**: +$395.76 (+6.26% from February)

### Top Cost Drivers (March)
1. Virtual Machines: +$129 (33% of increase)
2. SQL Databases: +$91 (23%)
3. Application Gateways: +$69 (17%)
4. Storage: +$56 (14%)
5. Other: +$51 (13%)

### Resource Distribution
- VMs: 30% of total costs
- SQL Databases: 20%
- Application Gateways: 15%
- Storage: 17%
- Disks: 5%
- Recovery Services: 4%
- Other: 9%

## Cost Optimization Opportunities

### High Priority (Save 20-30%)
- Right-size oversized VMs (potential savings: $100-200/month)
- Downgrade unused database tiers (potential savings: $50-150/month)
- Delete unused storage/disks (potential savings: $30-50/month)

### Medium Priority (Save 10-20%)
- Use Reserved Instances for predictable workloads (30-50% discount)
- Implement auto-shutdown policies
- Consolidate storage accounts (reduce management overhead)

### Low Priority (Save 5-10%)
- Use Spot instances for batch/test workloads (70-90% discount)
- Implement storage lifecycle policies
- Consolidate network resources

## Monthly Workflow

1. **First business day of month** - Automatic cost analysis runs
2. **Review report** - CloudOps team reviews findings
3. **Identify actions** - Prioritize optimization opportunities
4. **Implement changes** - Apply recommendations
5. **Track savings** - Monitor impact in next month's report

## References

- **Azure Cost Management**: https://portal.azure.com (Cost Management + Billing)
- **Reserved Instances**: https://learn.microsoft.com/en-us/azure/virtual-machines/reserved-vms-overview
- **Cost Optimization**: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/govern/cost-management/
- **Full Analysis Report**: See PROD-Subscription-Comprehensive-Analysis.md

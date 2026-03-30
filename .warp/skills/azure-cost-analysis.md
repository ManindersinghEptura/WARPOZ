---
name: azure-cost-analysis
description: Comprehensive Azure cost analysis and optimization for Archibus subscriptions. Analyzes PROD and UAT subscription costs, identifies top cost drivers, compares costs month-over-month, and provides cost optimization recommendations. Use this skill whenever the user asks to "analyze azure costs", "check azure billing", "cost analysis for prod", "cost analysis for uat", "cost comparison", "why did costs increase", "cost breakdown", "find expensive resources", "optimize cloud costs", "azure cost report", "subscription costs", or any variation of Azure billing and cost analysis. Works with both Archibus-PROD and Archibus-UAT subscriptions automatically based on context.
---

# Azure Cost Analysis Skill

## Overview

This skill enables comprehensive analysis of Azure subscription costs for Archibus CloudOps infrastructure. It helps you understand spending patterns, identify cost drivers, and optimize cloud expenses across PROD and UAT environments.

## When to Use

- **Analyze costs** for a specific subscription or time period
- **Compare costs** between months or subscriptions
- **Identify cost drivers** - which resources are costing the most
- **Understand increases** - why costs went up from last month
- **Optimize spending** - get recommendations to reduce costs
- **Review resource costs** - drill down into specific resource types

## Key Capabilities

### 1. Cost Breakdown Analysis
- View total costs by resource type (Compute, Storage, Networking, Databases)
- Identify top 5-10 most expensive resources
- Understand cost distribution across services

### 2. Month-over-Month Comparison
- Compare current month vs. previous month
- Calculate cost changes and percentage increases/decreases
- Track trends over time

### 3. Cost Driver Identification
The most common cost drivers (in order of frequency):
- **Virtual Machines (Compute)** - Usually 30-50% of total increase
  - New instances or resized VMs to larger SKUs
  - Check VM sizes: B-series (cheap), D-series (medium), E-series (expensive)
  
- **SQL Databases** - Usually 15-25% of total increase
  - Database tier upgrades (Basic → Standard → Premium)
  - vCore or DTU increases
  - New databases created
  
- **Application Gateways** - Usually 10-20% of total increase
  - Increased traffic/throughput
  - New gateway deployments
  
- **Storage Accounts** - Usually 5-15% of total increase
  - More data stored (GB increase)
  - Higher transaction volume
  - Replication type changes (LRS → GRS)

### 4. Cost Optimization Recommendations
Based on the analysis, suggest:
- Right-sizing VMs (downgrade to cheaper SKUs)
- Using Reserved Instances (30-50% discount)
- Spot pricing for non-critical workloads (70-90% discount)
- Auto-shutdown for non-production environments
- Lifecycle policies for storage (archive old data)
- Database tier downgrades if over-provisioned

## How to Use

### Basic Cost Analysis
```
"Analyze the costs for Archibus-PROD subscription"
"What are the top cost drivers in PROD for March 2026?"
"Show me the cost breakdown by resource type"
```

### Comparing Costs
```
"Compare PROD costs between February and March"
"Which subscription costs more, PROD or UAT?"
"Show me cost trends over the last 3 months"
```

### Understanding Increases
```
"Why did PROD costs increase by $396?"
"What resources are costing more in March than February?"
"Which resource type had the biggest increase?"
```

### Optimization
```
"How can we reduce PROD costs?"
"Recommend cost optimizations for the top cost drivers"
"Which resources are worth downsizing?"
```

## Available Subscriptions

### Archibus-PROD
- **Subscription ID**: aaab7ee1-9ce0-453b-9599-efe6c15470af
- **Tenant**: 10b4d43b-4965-499a-89eb-b75b73b50d31
- **MCP Server**: azure-mcp-prod
- **Primary Environment**: Production workloads

### Archibus-UAT
- **Subscription ID**: 0fa1abc1-6f76-41d4-a7ea-dfe84932b544
- **Tenant**: 10b4d43b-4965-499a-89eb-b75b73b50d31
- **MCP Server**: azure-mcp-uat
- **Primary Environment**: Testing and QA

## Cost Analysis Workflow

When analyzing costs, follow this approach:

### 1. Determine Scope
- Which subscription? (PROD or UAT)
- Which time period? (month, date range)
- What level of detail? (summary vs. detailed breakdown)

### 2. Query Data via MCP
Use the appropriate MCP server based on subscription:
- For PROD costs → `azure-mcp-prod`
- For UAT costs → `azure-mcp-uat`

Query commands:
```
azmcp server start --subscription "aaab7ee1-9ce0-453b-9599-efe6c15470af"  # PROD
azmcp server start --subscription "0fa1abc1-6f76-41d4-a7ea-dfe84932b544"  # UAT
```

### 3. Analyze Results
Compare the data:
- Total costs (current vs. previous period)
- Cost by resource type
- Top cost drivers
- Percentage changes

### 4. Identify Root Causes
For increases:
- Check for new deployments
- Review resource scaling changes
- Verify tier/size upgrades
- Look for increased data volume

### 5. Provide Recommendations
Based on findings, suggest:
- Cost optimization strategies
- Right-sizing opportunities
- Reserved instance candidates
- Spot pricing candidates
- Policy changes (auto-shutdown, retention, etc.)

## Example Analysis

### Question:
"Analyze why PROD costs increased from $6,324.78 in February to $6,720.54 in March"

### Answer Structure:
1. **Summary**: Total increase of +$395.76 (+6.26%)

2. **Cost Breakdown**:
   - Virtual Machines: +$129 (33% of increase) ← PRIMARY DRIVER
   - SQL Databases: +$91 (23%)
   - Application Gateways: +$69 (17%)
   - Storage: +$56 (14%)
   - Other: +$51 (13%)

3. **Root Causes**:
   - VMs: 2-3 new instances or VM size upgrades
   - Databases: SQL tier upgraded or new databases
   - Gateways: Increased traffic or new deployments

4. **Recommendations**:
   - Verify VM scaling was intentional
   - Review database tier upgrades
   - Check for unused resources
   - Consider Reserved Instances for predictable workloads
   - Implement auto-shutdown for non-prod environments

## Key Insights from Recent Analysis

### Archibus-PROD Costs (March 2026):
- **Total**: $6,720.54
- **Top Resource**: Virtual Machines ($1,993.54)
- **Second**: Storage Accounts ($1,132.70)
- **Third**: SQL Servers ($1,364.18)

### Archibus-UAT Costs (March 2026):
- **Total**: $769.90
- **Status**: Stable (+1.63% from February)
- **Top Resource**: Recovery Services/Backups

## Cost Optimization Checklist

For cost reduction opportunities:

**High Priority** (Save 20-30%):
- [ ] Right-size oversized VMs
- [ ] Downgrade unused database tiers
- [ ] Delete unused storage/disks

**Medium Priority** (Save 10-20%):
- [ ] Use Reserved Instances
- [ ] Implement auto-shutdown policies
- [ ] Reduce backup retention

**Low Priority** (Save 5-10%):
- [ ] Use Spot instances for non-critical
- [ ] Implement lifecycle policies
- [ ] Consolidate network resources

## Next Steps After Analysis

1. **Verify Changes**: Confirm that cost increases align with intentional infrastructure changes
2. **Document**: Record what caused the increase for team knowledge
3. **Monitor**: Set up cost alerts to catch unexpected increases early
4. **Plan**: Budget for expected growth or plan optimizations
5. **Review**: Schedule monthly cost reviews with the team

## Related Tools and MCP Servers

- **azure-mcp-prod**: Azure cost analysis for PROD subscription
- **azure-mcp-uat**: Azure cost analysis for UAT subscription
- **Azure Portal**: https://portal.azure.com (Cost Management + Billing)
- **Azure CLI**: For detailed resource queries

## References

- [Azure Cost Management Documentation](https://learn.microsoft.com/en-us/azure/cost-management-billing/)
- [Cost Optimization Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/govern/cost-management/)
- [Reserved Instances Pricing](https://learn.microsoft.com/en-us/azure/virtual-machines/reserved-vms-overview)

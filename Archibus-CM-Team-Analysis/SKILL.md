---
name: Archibus-CM-Team-Analysis
description: Comprehensive team lead analysis for Archibus tickets in Change Management project. Provides assignment distribution, workload analysis, aging insights, priority breakdowns, and actionable team management recommendations. Use when the user asks to "analyze team tickets", "team lead analysis", "check team workload", "archibus team status", "CM team overview", "ticket distribution", "assignment analysis", or any variation of team management analysis for Archibus CloudOps tickets.
---

# Archibus CM Team Analysis

Comprehensive team management analysis for Archibus tickets in the Change Management project, providing actionable insights for CloudOps team leads.

## Core Functionality

### 1. Primary Analysis Commands

**Full Team Analysis**: Complete team lead dashboard
```
Use JQL: project = "Change Management" and "Category and Sub-category[Select List (cascading)]" = Archibus and status NOT IN (Cancelled,Done) ORDER BY assignee ASC, status ASC
```

**Assignment Distribution**: Focus on workload balance
```  
Use JQL: project = "Change Management" and "Category and Sub-category[Select List (cascading)]" = Archibus and status NOT IN (Cancelled,Done) ORDER BY assignee ASC
```

**Age Analysis**: Find critical aging tickets
```
Use JQL: project = "Change Management" and "Category and Sub-category[Select List (cascading)]" = Archibus and status = "More Info Needed" ORDER BY created ASC
```

**Priority Review**: Focus on high-impact tickets
```
Use JQL: project = "Change Management" and "Category and Sub-category[Select List (cascading)]" = Archibus and status NOT IN (Cancelled,Done) ORDER BY priority DESC, created ASC
```

### 2. Analysis Categories

**Team Member Workload Analysis**:
- Active ticket count per assignee
- Status distribution for each team member
- Identify overloaded vs underutilized resources
- Specialization patterns (who handles what types)

**Status Health Indicators**:
- **More Info Needed**: Tickets requiring customer/external input
- **Approved**: Ready to execute, prioritize these
- **In Progress**: Currently being worked, track progress
- **Under Observation**: Monitoring phase, set SLA expectations
- **New Issue**: Unassigned/unprocessed tickets

**Aging Critical Points**:
- Tickets > 365 days (critical escalation needed)
- Tickets > 180 days (management attention required)  
- Tickets > 90 days (follow-up needed)
- Status-specific aging thresholds

**Priority Distribution**:
- Highest/High priority ticket accountability
- Medium priority volume management
- Unassigned priority tickets

### 3. Team Lead Workflow

1. **Collect Data**: Run primary JQL to get all active Archibus tickets
2. **Assignment Analysis**: Group by assignee and calculate distribution
3. **Status Analysis**: Categorize by status and identify bottlenecks
4. **Age Analysis**: Identify critically aged tickets requiring escalation
5. **Priority Analysis**: Ensure high-priority items have proper attention
6. **Generate Action Plan**: Provide specific next steps for team management

### 4. Key Analysis Points

**Workload Balance Indicators**:
- Team members with >15 active tickets (overloaded)
- Team members with <5 active tickets (potentially available)
- Status distribution patterns (too many "Under Observation")

**Process Health Signals**:
- High volume of "More Info Needed" = communication issues
- Many "Under Observation" tickets = follow-up process needed
- Old "Approved" tickets = execution bottleneck

**Escalation Triggers**:
- Any ticket >1 year old
- "Highest" priority tickets not in progress
- Team members with consistently aging tickets

### 5. Output Format

```markdown
🎯 **ARCHIBUS TEAM ANALYSIS** (X Active Tickets)

👥 **TEAM WORKLOAD DISTRIBUTION**
• **[Name]** (X tickets): Y Approved, Z Under Observation, A More Info Needed
  - ⚠️ Overloaded | ✅ Balanced | 📈 Available
• **[Name]** (X tickets): Y Approved, Z Under Observation, A More Info Needed

📊 **STATUS BREAKDOWN**  
• More Info Needed: X tickets (Y% of total)
• Under Observation: X tickets (Y% of total) 
• Approved: X tickets (Y% of total)
• In Progress: X tickets (Y% of total)

⚰️ **CRITICAL AGING ISSUES**
• **IMMEDIATE ACTION**: [Ticket] - X days old - [Assignee]
• **ESCALATION NEEDED**: [Ticket] - X days old - [Assignee]

🔥 **PRIORITY ANALYSIS**
• Highest: X tickets - [Status summary]
• High: X tickets - [Status summary]
• Medium: X tickets - [Status summary]

## 🚨 IMMEDIATE TEAM ACTIONS:
1. [Specific actionable item with assignee]
2. [Process improvement needed]
3. [Resource rebalancing recommendation]

## 📋 WEEKLY TEAM ACTIONS:
1. [Recurring management task]
2. [Process checkpoint]
3. [Team review recommendation]
```

### 6. Advanced Features

**Trend Analysis**: Compare with previous analysis to identify:
- Tickets moving between team members
- Status progression patterns
- Team velocity indicators

**Resource Optimization**: Suggest workload redistribution based on:
- Current capacity
- Skill specialization
- Ticket priority and complexity

**Process Improvement**: Identify systemic issues:
- Tickets consistently aging in specific statuses
- Assignment patterns that create bottlenecks
- Communication gaps requiring process changes

### 7. Integration Points

- **Leverages Jira-MCPServer** for efficient batch ticket queries
- **Complements existing triage workflows** with team management focus
- **Can be scheduled for weekly team reviews** on Oz
- **Integrates with Teams notifications** for leadership updates

## Teams Leadership Notifications

**Weekly Team Reports**: Send comprehensive analysis to leadership team with:
- Executive summary statistics
- Critical escalation items requiring management attention
- Resource allocation recommendations
- Process improvement opportunities

**Alert Notifications**: Trigger immediate notifications for:
- Tickets aging beyond critical thresholds
- Team members with extreme workload imbalances
- High-priority tickets without progress

### Notification Setup
1. Create Teams webhook for leadership channel
2. Store as Oz secret: `oz secret create TEAMS_LEADERSHIP_WEBHOOK --team --value "https://..."`
3. Schedule weekly analysis with leadership reporting

### Sample Oz Deployment

**Create Environment**:
```bash
oz environment create \
  --name "archibus-teamlead-analysis" \
  --description "Weekly Archibus team management analysis and reporting" \
  --base-image "warpdotdev/dev-base:latest" \
  --setup-commands "apt-get update && apt-get install -y python3-pip && pip3 install requests"
```

**Schedule Weekly Analysis**:
```bash
oz schedule create \
  --name "weekly-team-analysis" \
  --cron "0 9 * * 1" \
  --prompt "Use the Archibus-CM-Team-Analysis skill to perform comprehensive team analysis of all Archibus tickets. Include assignment distribution, aging analysis, priority review, and actionable recommendations for team management. Send Teams notification to leadership with critical items requiring attention." \
  --environment "archibus-teamlead-analysis"
```

## Usage Examples

**Weekly Review**: "run team analysis" or "archibus team status"
**Resource Planning**: "check team workload" or "assignment distribution"  
**Escalation Review**: "analyze aging tickets" or "critical tickets review"
**Priority Check**: "high priority ticket status" or "priority distribution"
**Process Health**: "team process analysis" or "status bottlenecks"
**With Leadership Report**: "team analysis with leadership notification"

The skill automatically provides comprehensive team management insights with actionable recommendations for optimizing CloudOps team performance and process efficiency.
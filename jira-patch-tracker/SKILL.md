---
name: jira-patch-tracker
description: Automated analysis and tracking of patch tickets in Jira Change Management project. Provides smart categorization of patch tickets by readiness status, dependency analysis, and actionable recommendations. Use when the user asks to "analyze patches", "check patch status", "review patch tickets", "find ready patches", "patch triage", "patch dependencies", or any variation of patch ticket tracking and analysis.
---

# Jira Patch Tracker

Automated analysis and tracking of Archibus patch tickets with smart dependency analysis and actionable recommendations.

## Core Functionality

### 1. Patch Analysis Commands

**Primary Analysis**: Run comprehensive patch ticket analysis
```
Use JQL: summary ~"patch" and project = "Change Management" and status NOT IN (Closed,Cancelled,Done,Rejected) ORDER BY priority DESC, created ASC
```

**Ready-to-Work Filter**: Find immediately actionable tickets
```  
Use JQL: summary ~"patch" and project = "Change Management" and status NOT IN (Closed,Cancelled,Done,Rejected,In Progress,"Ready for QA","In QA") ORDER BY priority DESC
```

### 2. Analysis Categories

Categorize each patch ticket into one of these statuses:

**✅ READY TO START**
- All blocking AD tickets are "Done" 
- CM ticket status allows work (not In Progress/Testing)
- No pending dependencies

**⏳ BLOCKED BY DEPENDENCIES**
- Has blocking AD tickets in: In Progress, Code Review, Ready for Dev, More Info Needed
- Dependencies not yet resolved

**🔄 IN PROGRESS/TESTING**  
- CM ticket status: In Progress, Ready for QA, In QA
- OR blocking AD tickets in: Ready for QA, In QA

**⚠️ NEEDS REVIEW**
- Status "More Info Needed" but all dependencies appear resolved
- Potential status sync issues

### 3. Workflow

1. **Fetch Tickets**: Run the main JQL filter to get all active patch tickets
2. **Analyze Dependencies**: For each ticket, check all linked issues (especially AD tickets)
3. **Categorize**: Place each ticket in appropriate readiness category
4. **Prioritize**: Within each category, order by priority then creation date
5. **Generate Report**: Provide actionable summary with next steps

### 4. Key Analysis Points

**Dependency Check Pattern**:
- Look for issue links with types: "is blocked by", "depends on"  
- Focus on AD (Archibus Dev) project tickets
- Check if engineering work is complete (Done status)

**Status Translation**:
- "More Info Needed" + dependencies Done = Ready to Start
- "Approved" = Ready to Start  
- "In Progress" = Currently being worked
- "Ready for QA"/"In QA" = Testing phase

**Priority Handling**:
- High priority tickets get top placement in Ready to Start
- Age factor: Older tickets (created earlier) get priority within same priority level

### 5. Output Format

```markdown
🎯 **PATCH TICKET ANALYSIS** (X found)

✅ **READY TO START (X tickets)**
- CM-XXXXX (Priority) - Brief reason/status
- CM-XXXXX (Priority) - Brief reason/status

⏳ **BLOCKED BY DEPENDENCIES (X tickets)** 
- CM-XXXXX (Priority) - Blocked by AD-XXXXX (Status)
- CM-XXXXX (Priority) - Blocked by AD-XXXXX (Status)

🔄 **IN PROGRESS/TESTING (X tickets)**
- CM-XXXXX (Priority) - Current status/phase
- CM-XXXXX (Priority) - Current status/phase

⚠️ **NEEDS REVIEW (X tickets)**
- CM-XXXXX (Priority) - Issue description

## IMMEDIATE ACTIONS:
1. Start work on Ready to Start tickets (highest priority first)
2. Follow up on old blocked tickets  
3. Review tickets needing status updates
```

### 6. Advanced Features

**Trend Analysis**: Compare current state to previous runs to identify:
- Newly unblocked tickets
- Tickets that became blocked  
- Status changes requiring attention

**Aging Analysis**: Flag tickets that have been in same status too long:
- More Info Needed > 30 days
- Blocked > 60 days
- In Progress > 45 days

**Assignment Analysis**: Show workload distribution and identify unassigned ready tickets

### 7. Integration Points

- **Works with existing Jira MCP connection** 
- **Leverages Jira-MCPServer tools** for efficient batch queries
- **Complements existing triage workflows** 
- **Can be scheduled for daily automation**

## Teams Notifications

**Automatic Notifications**: When scheduled on Oz, can automatically send Teams notifications with analysis results.

**Manual Notifications**: Use `python3 scripts/teams_notify.py` with JSON analysis data to send immediate notifications.

**Teams Message Format**: Rich cards with:
- Summary statistics (Ready/Blocked/In Progress counts)
- Top 5 tickets in each category  
- Direct links to Jira filter
- Color-coded priority indicators

### Notification Setup
1. Create Teams incoming webhook in your channel
2. Store webhook URL as Oz secret: `oz secret create TEAMS_WEBHOOK_URL --team --value "https://..."`
3. Schedule the agent with notification enabled

### Sample Oz Deployment

**Create Environment**:
```bash
oz environment create \
  --name "patch-tracker" \
  --description "Automated patch ticket analysis with Teams notifications" \
  --base-image "warpdotdev/dev-base:latest" \
  --setup-commands "apt-get update && apt-get install -y python3-pip && pip3 install requests"
```

**Schedule Daily Analysis**:
```bash
oz schedule create \
  --name "daily-patch-triage" \
  --cron "0 8 * * 1-5" \
  --prompt "Use the jira-patch-tracker skill to analyze all patch tickets and send Teams notification with results. Focus on actionable insights and highlight any newly unblocked tickets." \
  --environment "patch-tracker"
```

## Usage Examples

**Daily Triage**: "Run patch analysis" or "analyze patches"
**Quick Check**: "Show ready patches" or "what patches can we start?"  
**Dependency Review**: "Check patch blockers" or "patch dependencies"
**Status Update**: "Review patch status changes"
**With Notifications**: "Analyze patches and send Teams notification"

The skill automatically determines the appropriate level of analysis based on user request context and provides actionable recommendations for patch pipeline management.

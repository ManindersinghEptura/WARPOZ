# Patch Ticket Tracker Skill

## Objective
Analyze Archibus Change Management (CM) patch tickets, categorize by readiness status, and send a Teams notification with the analysis summary.

## Instructions

You MUST follow these steps in order:

### Step 1: Query Patch Tickets
Use the Jira MCP tool `jira_search` with:
- **JQL**: `summary ~ patch AND project = CM AND status NOT IN (Closed, Cancelled, Done, Rejected) ORDER BY priority DESC, created ASC`
- **Fields**: `summary,status,priority,assignee,created,updated,labels,key`
- **Limit**: 50

Execute this search and capture the results.

### Step 2: Analyze Each Ticket
For each patch ticket returned:
1. Extract: key, summary, status, priority, assignee
2. Determine readiness:
   - **Ready to Start**: status = "To Do", no assignee, no blockers
   - **Blocked**: Has dependencies not yet complete OR assignee marked as "Waiting for"
   - **In Progress**: status = "In Progress" OR assigned to team member
   - **Needs Review**: status = "In Review" OR "Testing" OR "Approval"

### Step 3: Build JSON Summary
Create a JSON object with this structure:
```json
{
  "timestamp": "YYYY-MM-DD HH:MM:SS UTC",
  "ready_to_start": [
    {"key": "CM-XXX", "summary": "...", "priority": "High"}
  ],
  "blocked": [
    {"key": "CM-YYY", "summary": "...", "blocker": "reason"}
  ],
  "in_progress": [
    {"key": "CM-ZZZ", "summary": "...", "assignee": "name"}
  ],
  "needs_review": [
    {"key": "CM-AAA", "summary": "...", "status": "In Review"}
  ]
}
```

Print this JSON to stdout as valid JSON (no extra text before/after).

### Step 4: Send Teams Notification
Execute Python script to send Teams notification:
```bash
python3 /repo/simple_patch_tracker.py --notify --data '<JSON_FROM_STEP_3>'
```

Replace `<JSON_FROM_STEP_3>` with the actual JSON from Step 3.

### Step 5: Report Summary
Print completion message with:
- Total patches analyzed
- Count in each category
- Any critical issues (e.g., high-priority blockers)

## Expected Output
- Teams message card posted to webhook
- Console output showing analysis summary
- Status: Done or Error

## Environment Variables
- `TEAMS_WEBHOOK_URL`: Microsoft Teams incoming webhook URL (provided by Oz environment)

## Success Criteria
- At least 1 patch ticket queried from CM project
- JSON summary created with all 4 categories
- Teams notification successfully delivered (HTTP 200)
- Completion message printed

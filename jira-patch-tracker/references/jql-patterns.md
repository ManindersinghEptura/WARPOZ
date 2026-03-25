# JQL Patterns for Patch Tracking

## Core Filter Queries

### Main Patch Filter
```jql
summary ~"patch" and project = "Change Management" and status NOT IN (Closed,Cancelled,Done,Rejected) ORDER BY priority DESC, created ASC
```
**Purpose**: Get all active patch tickets, prioritized by importance and age

### Ready-to-Work Filter  
```jql
summary ~"patch" and project = "Change Management" and status NOT IN (Closed,Cancelled,Done,Rejected,In Progress,"Ready for QA","In QA") ORDER BY priority DESC
```
**Purpose**: Focus on tickets that aren't currently being worked or tested

### High Priority Patches
```jql
summary ~"patch" and project = "Change Management" and priority = High and status NOT IN (Closed,Cancelled,Done,Rejected)
```

### Aging Patches (Over 30 days)
```jql
summary ~"patch" and project = "Change Management" and status = "More Info Needed" and created < -30d
```

## Status Analysis Patterns

### CM Ticket Status Meanings

| Status | Interpretation | Action |
|--------|---------------|--------|
| `More Info Needed` | Waiting for clarification or dependencies | Check if blockers resolved |
| `Approved` | Ready to start work | Begin implementation |
| `In Progress` | Currently being worked | Monitor progress |
| `Ready for QA` | Testing phase | Monitor QA completion |
| `In QA` | Active testing | Wait for results |

### AD Ticket Status Meanings (Dependencies)

| Status | Interpretation | Impact on CM |
|--------|---------------|--------------|
| `Done` | Engineering complete | CM can proceed ✅ |
| `Ready for QA` | Engineering done, testing | CM nearly ready |
| `In QA` | Active testing | CM should wait |
| `In Progress` | Active development | CM blocked |
| `Code Review` | Nearly done | CM still blocked |
| `Ready for Dev` | Not started | CM blocked |
| `More Info Needed` | Clarification needed | CM blocked |

## Link Type Analysis

### Blocking Relationships
- `"is blocked by"` - CM ticket cannot proceed until linked ticket is Done
- `"depends on"` - Similar to blocked by, dependency relationship
- `"Blocks"` - This ticket blocks others (reversed relationship)

### Non-Blocking Relationships  
- `"relates to"` - Related but not blocking
- `"Organization"` - Organizational link, usually not blocking
- `"Customer CMDB"` - Environment reference, not blocking
- `"Work item split"` - Split relationship, check context

## Advanced Query Patterns

### Find Unblocked Patches
```jql
summary ~"patch" and project = "Change Management" 
and status = "More Info Needed" 
and issue in linkedIssues("project = AD and status = Done")
```

### Find Old Blocked Patches
```jql
summary ~"patch" and project = "Change Management" 
and status NOT IN (Done,Closed,Cancelled,Rejected)
and created < -60d
and issue in linkedIssues("project = AD and status NOT IN (Done)")
```

### Patches by Assignee Workload
```jql
summary ~"patch" and project = "Change Management" 
and status IN ("In Progress","Approved") 
and assignee = "shobhit.mishra@eptura.com"
```

## Batch Analysis Queries

When analyzing large numbers of tickets, use these approaches:

### Get Tickets with Links (Efficient)
```jql
summary ~"patch" and project = "Change Management" 
and status NOT IN (Closed,Cancelled,Done,Rejected)
and issueLinks is not EMPTY
ORDER BY priority DESC, created ASC
```

### Focus on AD Dependencies
```jql
summary ~"patch" and project = "Change Management"
and status NOT IN (Closed,Cancelled,Done,Rejected)  
and issue in linkedIssues("project = AD")
```

## Query Optimization Tips

1. **Use batch queries** with issuelinks expansion when possible
2. **Limit results** initially, then drill down for details  
3. **Order strategically** - priority DESC, created ASC for best triage order
4. **Cache link analysis** to avoid repeated API calls for same tickets
5. **Focus on actionable states** - exclude clearly blocked or completed tickets

## Field Mapping for Analysis

### Essential Fields to Fetch
- `key, summary, status, priority, assignee, created, updated, issuelinks`

### Expanded Fields for Deep Analysis  
- `*all` when detailed analysis needed
- `changelog` for status history tracking
- `comments` for recent updates (limit to last 3-5)

### Performance vs Detail Balance
- **Quick triage**: Essential fields only
- **Daily analysis**: Essential + issuelinks expanded  
- **Deep investigation**: Full fields + changelog + comments
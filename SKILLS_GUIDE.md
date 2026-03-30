# Oz Skills Discovery Guide

## How Oz Finds Your Skills

When you create an Oz environment pointing to the **WARPOZ** repository, Oz automatically scans for SKILL.md files in the `.warp/skills/` directory.

Oz reads the skill name from the **YAML frontmatter** in each SKILL.md file:

```yaml
---
name: cost-analysis-prod      # ← Oz uses this as the skill name
description: ...
---
```

## Your Skills Structure

```
WARPOZ/
├── .warp/
│   └── skills/
│       ├── azure-cost-analysis.md           # Skill name: "azure-cost-analysis"
│       ├── cost-analysis-prod/
│       │   └── SKILL.md                     # Skill name: "cost-analysis-prod"
│       └── cost-analysis-uat/
│           └── SKILL.md                     # Skill name: "cost-analysis-uat"
├── apollo-logs-skill/
├── Archibus-CM-Team-Analysis/
├── archibus-team-mcp-server/
├── Azure/
├── jira-patch-tracker/
└── ... other directories
```

## How Oz References Skills

### In the Oz Web App
When creating a schedule or running an agent:

1. Go to https://oz.warp.dev/schedules
2. Click "New schedule"
3. Under **Agent**, select from:
   - `azure-cost-analysis` ← Will be available
   - `cost-analysis-prod` ← Will be available
   - `cost-analysis-uat` ← Will be available

### Via Oz CLI

```bash
# Run PROD cost analysis
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "cost-analysis-prod" \
  --prompt "Generate monthly cost report"

# Run UAT cost analysis
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "cost-analysis-uat" \
  --prompt "Check UAT spending trends"

# Run generic cost analysis
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "azure-cost-analysis" \
  --prompt "Analyze costs"
```

### Via Oz API

```json
{
  "prompt": "Generate monthly cost analysis",
  "config": {
    "environment_id": "<ENV_ID>",
    "skill_spec": "cost-analysis-prod"
  }
}
```

## Skill Discovery Requirements

For Oz to find and use your skills:

✅ **Required:**
- Repository added to an Oz environment
- SKILL.md files in `.warp/skills/` directory
- YAML frontmatter with `name:` field at top of file
- Each skill has unique name

❌ **NOT required:**
- File names (can be anything)
- Folder structure (any depth works)
- Specific file extensions (can use .md or .txt)

## Adding New Skills

To add a new skill to WARPOZ:

1. **Create directory** under `.warp/skills/`:
   ```
   .warp/skills/my-new-skill/
   ```

2. **Create SKILL.md** with YAML frontmatter:
   ```yaml
   ---
   name: my-new-skill
   description: What this skill does
   ---
   
   # My New Skill
   ... content ...
   ```

3. **Commit to git**:
   ```bash
   git add .warp/skills/my-new-skill/SKILL.md
   git commit -m "Add my-new-skill"
   ```

4. **Skill is available immediately** in Oz (no deployment needed)

## Your Current Skills

### 1. azure-cost-analysis
- **Location**: `.warp/skills/azure-cost-analysis.md`
- **Use**: Generic Azure cost analysis for any subscription
- **Trigger phrases**: "cost analysis", "analyze azure costs", "cost breakdown"

### 2. cost-analysis-prod
- **Location**: `.warp/skills/cost-analysis-prod/SKILL.md`
- **Use**: PROD subscription cost analysis (aaab7ee1-9ce0-453b-9599-efe6c15470af)
- **Focus**: Production costs, optimization for production workloads
- **Monthly costs**: ~$6,720/month (March 2026)
- **Schedule**: 1st of month at 9 AM (Cron: `0 9 1 * *`)

### 3. cost-analysis-uat
- **Location**: `.warp/skills/cost-analysis-uat/SKILL.md`
- **Use**: UAT subscription cost analysis (0fa1abc1-6f76-41d4-a7ea-dfe84932b544)
- **Focus**: Testing costs, optimization for non-production workloads
- **Monthly costs**: ~$769/month (March 2026)
- **Schedule**: Can run independently or with PROD analysis

## Next Steps

### 1. Create Oz Environment
```bash
oz environment create \
  --name "WARPOZ-skills" \
  --repo "your-github-org/WARPOZ" \
  --docker-image "python:3.12"
```

### 2. Create Scheduled Agent for PROD
Go to https://oz.warp.dev/schedules:
- **Name**: `Azure Cost Analysis - Monthly PROD Report`
- **Agent**: `cost-analysis-prod`
- **Environment**: `WARPOZ-skills`
- **Cron**: `0 9 1 * *` (1st of month at 9 AM)

### 3. Create Scheduled Agent for UAT (Optional)
- **Name**: `Azure Cost Analysis - Monthly UAT Report`
- **Agent**: `cost-analysis-uat`
- **Cron**: `0 9 2 * *` (2nd of month at 9 AM, after PROD)

### 4. Test in Oz Web App
Go to https://oz.warp.dev/schedules and click **Run now** to test

## Troubleshooting

### Skills Not Showing in Oz Web App

❌ **Problem**: Can't see `cost-analysis-prod` in the Agent dropdown

✅ **Solution**:
1. Verify environment points to WARPOZ repository
2. Check `.warp/skills/cost-analysis-prod/SKILL.md` exists
3. Verify SKILL.md has `name: cost-analysis-prod` in frontmatter
4. Commit changes to git: `git add .warp/skills/` && `git commit -m "..."`
5. Refresh Oz web app

### Wrong Skill Runs

❌ **Problem**: Selected `cost-analysis-prod` but it's running generic analysis

✅ **Solution**:
1. Check skill name in YAML frontmatter matches what you selected
2. Verify correct environment is selected
3. Check git commit was successful

### Environment Not Pointing to WARPOZ

❌ **Problem**: Environment was created before pushing to GitHub

✅ **Solution**:
```bash
# Push WARPOZ to GitHub
cd D:\Archibus\KT\Warp\WARPOZ
git remote add origin https://github.com/<your-org>/WARPOZ.git
git push -u origin main

# Then create Oz environment pointing to GitHub
oz environment create --name "WARPOZ-skills" --repo "your-org/WARPOZ"
```

## Key Takeaway

**Skills are referenced by the `name:` field in SKILL.md, not by file names or folder names.**

This allows you to:
- ✅ Organize skills in logical folders
- ✅ Use descriptive folder names that differ from skill names
- ✅ Add multiple skills in one repo
- ✅ Update skills without breaking references
- ✅ Share a single repository across multiple teams

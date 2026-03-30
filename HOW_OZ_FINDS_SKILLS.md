# How Oz Finds Skills - Explained

## Your Original Question
> "I am confused how each skill will be referred by OZ, because we do not refer any file name or skill name or folder name in it"

## The Answer

Oz finds skills using the **YAML frontmatter `name:` field**, not file names or folder names.

### Example

Your PROD skill file:
```
.warp/skills/cost-analysis-prod/SKILL.md
```

Inside that file:
```yaml
---
name: cost-analysis-prod              # ← THIS is the skill identifier
description: Monthly cost analysis...
---
```

**When you use the skill in Oz**, you reference only the **skill name**:
```
Select Agent: "cost-analysis-prod"
```

NOT the file path or folder name.

---

## How Oz Actually Works

### Step 1: Discovery
Oz scans the repository for SKILL.md files in `.warp/skills/` directory:
```
.warp/skills/
├── azure-cost-analysis.md
├── cost-analysis-prod/
│   └── SKILL.md                ← Oz finds this
└── cost-analysis-uat/
    └── SKILL.md                ← And this
```

### Step 2: Reading
Oz reads the YAML frontmatter of each SKILL.md file:
```yaml
---
name: cost-analysis-prod              # ← Oz extracts this
description: ...
---
```

### Step 3: Registration
Oz registers the skill with its name:
- Skill registered as: `cost-analysis-prod`
- File location: `.warp/skills/cost-analysis-prod/SKILL.md`
- Folder name: (ignored)
- File name: (ignored)

### Step 4: Reference
You select it in Oz by name only:
```
Oz Web App → New Schedule → Agent dropdown → "cost-analysis-prod" ✓
```

---

## Why This Design?

### Flexibility
You can:
- ✅ Use descriptive folder names (`cost-analysis-prod` folder)
- ✅ Use different skill names (`name: cost-analysis-prod`)
- ✅ Organize however you want
- ✅ Rename files/folders without breaking references

### Example
These are all equivalent to Oz:

**Option A (Organized in folders):**
```
.warp/skills/cost-analysis-prod/SKILL.md
---
name: my-skill
---
```
→ Oz calls it: `my-skill`

**Option B (All in root):**
```
.warp/skills/my-skill.md
---
name: my-skill
---
```
→ Oz calls it: `my-skill`

**Option C (Different names):**
```
.warp/skills/cost-analysis-prod/production-report.md
---
name: prod-analyzer
---
```
→ Oz calls it: `prod-analyzer`

---

## Your Setup (WARPOZ Repository)

### Structure
```
.warp/skills/
├── azure-cost-analysis.md              Skill: "azure-cost-analysis"
├── cost-analysis-prod/
│   └── SKILL.md                        Skill: "cost-analysis-prod"
└── cost-analysis-uat/
    └── SKILL.md                        Skill: "cost-analysis-uat"
```

### How to Use
In Oz Web App (https://oz.warp.dev/schedules):

```
1. Click "New schedule"
2. Name: "Azure Cost Analysis - Monthly PROD"
3. Agent dropdown shows:
   • azure-cost-analysis         ← Select this (file: azure-cost-analysis.md)
   • cost-analysis-prod          ← Or this (file: cost-analysis-prod/SKILL.md)
   • cost-analysis-uat           ← Or this (file: cost-analysis-uat/SKILL.md)
4. Select: "cost-analysis-prod"
5. Create schedule
```

Via CLI:
```bash
oz agent run-cloud \
  --environment <ENV_ID> \
  --skill "cost-analysis-prod" \        # ← Skill name (from YAML)
  --prompt "Generate cost report"
```

---

## The Key Difference

### ❌ Wrong Understanding
"Oz uses file names or folder names to find skills"

### ✅ Correct Understanding
"Oz finds SKILL.md files and reads the `name:` field from YAML frontmatter"

### Why It Matters
This separation allows:
1. **Consistent naming** - Skills always known by their `name:` field
2. **Flexible organization** - Folder structure doesn't affect skill references
3. **Easy sharing** - Multiple teams can use same repo without conflicts
4. **Stable references** - Renaming files/folders won't break schedules

---

## Common Confusion Points

### Confusion 1: "Which file will be used?"
**Question**: If I have `cost-analysis-prod/SKILL.md`, how does Oz know which file?

**Answer**: Oz looks in `.warp/skills/` directory for any files named `SKILL.md` (or other SKILL files). The file path doesn't matter - only the `name:` field in YAML.

### Confusion 2: "What if I have the same name in two files?"
**Question**: If `prod/SKILL.md` and `uat/SKILL.md` both have `name: analyzer`, what happens?

**Answer**: Don't do this - each skill must have a unique `name:` field. Oz will use the first one it finds (implementation-dependent).

### Confusion 3: "How does Oz know which folder to look in?"
**Question**: Does Oz look in `.warp/skills/` or `.agents/skills/`?

**Answer**: Oz checks multiple directories in order:
1. `.warp/skills/` ← First
2. `.agents/skills/`
3. `.claude/skills/`
4. etc.

Use `.warp/skills/` (industry standard for Oz).

---

## Summary

**Before (Confusion):**
> "How do I tell Oz which skill file to use? There's no file path or name specified!"

**After (Understanding):**
> "Oz finds all SKILL.md files in `.warp/skills/` and registers them by their YAML `name:` field. I reference skills by this name only, not by file paths."

**Your three skills in Oz:**
1. `cost-analysis-prod` (from `.warp/skills/cost-analysis-prod/SKILL.md`)
2. `cost-analysis-uat` (from `.warp/skills/cost-analysis-uat/SKILL.md`)
3. `azure-cost-analysis` (from `.warp/skills/azure-cost-analysis.md`)

You reference them ONLY by their names, regardless of where the files are located.

---
name: bug-hunter
description: Autonomously hunts for bugs and performance issues across a codebase by running three specialist sub-agents in parallel (regression, long-standing, and performance). Creates GitHub issues for confirmed findings. Designed to run in autonomous loops.
---

# Bug Hunter

Run three specialist agents in parallel to find regressions, long-standing bugs, and performance issues across the current repository, then raise GitHub issues for every confirmed finding.

## Usage

```
/bug-hunter
```

No arguments required. The skill is designed to run unattended in an autonomous loop.

## Process

### Step 1: Verify the Repository

```bash
gh repo view --json nameWithOwner,url
git status
```

Confirm this is a GitHub repository with a remote. If not, stop and report.

### Step 2: Run the Three Specialist Agents in Parallel

Spawn all three agents simultaneously using the Agent tool. Do not wait for one before starting the others — launch all three at the same time:

1. **Agent type: `regression-bug-hunter`**
   Prompt: "Analyse this repository for bugs introduced by recent commits. Focus on the last 10–15 commits. Return findings in the specified format."

2. **Agent type: `longstanding-bug-hunter`**
   Prompt: "Audit this repository for long-standing latent bugs. Do a broad analysis of the codebase, focusing on core business logic, error handling, and common bug patterns. Return findings in the specified format."

3. **Agent type: `performance-bug-hunter`**
   Prompt: "Analyse this repository for performance problems and future scaling concerns. Identify the project type first to tailor your analysis. Return findings in the specified format."

Wait for all three to complete before proceeding.

### Step 3: Parse and Collect Findings

Collect all findings from the three agent responses. Each finding has a type prefix: `[BUG]` or `[PERFORMANCE]`.

Discard any agent response that returned `NO_FINDINGS`. If all three returned `NO_FINDINGS`, log a single message: "Bug hunter found no issues this run." and stop.

### Step 4: Deduplicate

Compare findings across agents. If two or more agents reported what is clearly the same underlying issue (same file, same line, same root cause), keep only the most detailed version. Do not create duplicate issues.

### Step 5: Check for Existing Open Issues

```bash
gh issue list --state open --limit 200 --json title
```

For each finding, check whether an open issue with a substantially similar title already exists. If one does, skip that finding — do not create a duplicate.

### Step 6: Create GitHub Issues

For each remaining finding, create a GitHub issue directly using `gh issue create`. Do not ask for user confirmation — this skill is designed for autonomous operation.

Map finding types to labels:
- `[BUG]` → label `bug`
- `[PERFORMANCE]` → label `enhancement`

Ensure the labels exist before creating issues:

```bash
gh label list --json name
```

Create any missing labels:
```bash
gh label create "bug" --color "#d73a4a" --description "Something is broken" 2>/dev/null || true
gh label create "enhancement" --color "#a2eeef" --description "Improvement to existing functionality" 2>/dev/null || true
```

For each `[BUG]` finding, create the issue with this body structure:

```markdown
## Problem

{problem from finding}

## Fix

{fix from finding}

## Requirements

{requirements list from finding}

---
*Raised by the bug-hunter autonomous agent.*
```

For each `[PERFORMANCE]` finding, create the issue with this body structure:

```markdown
## Overview

{context and problem from finding}

## Goal

Resolve the identified performance concern before it impacts users or becomes harder to fix at scale.

## Requirements

{requirements list from finding}

---
*Raised by the bug-hunter autonomous agent.*
```

Create each issue:

```bash
gh issue create \
  --title "{title}" \
  --body "$(cat <<'EOF'
{body}
EOF
)" \
  --label "{label}"
```

### Step 7: Report

After all issues are created, output a concise summary:

```
Bug hunter run complete.
- Regression findings: N
- Long-standing findings: N  
- Performance findings: N
- Issues created: N
- Issues skipped (already open): N
```

Include the URL of each newly created issue.

## Notes

- This skill is designed to run in autonomous loops — it creates issues without user confirmation.
- Severity is for internal triage; all findings above `Low` severity should be raised as issues. Skip `Low` severity findings unless they are in a particularly sensitive area (auth, payments, data integrity).
- Do not raise issues for code style, formatting preferences, or purely speculative future problems.
- Do not edit any files during this skill. It is strictly read and report.

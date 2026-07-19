# Rules

## NEVER EVER DO
These rules are ABSOLUTE:

### NEVER Publish Sensitive Data

- NEVER publish passwords, API keys, tokens to git/npm/docker
- Before ANY commit: verify no secrets included

### NEVER Commit .env Files

- NEVER commit `.env` to git
- ALWAYS verify `.env` is in `.gitignore`

### NEVER Hardcode Credentials

- ALWAYS use environment variables

### NEVER Commit to main

- NEVER commit directly onto `main` branches.
- ALWAYS create a `feature/*` branch for your work.

### NEVER Edit previous commits unless explicitly instructed

- NEVER edit a previous commit unless explicitly instructed to. If you are requested to make changes to previous changes simply append them as a new commit.

### NEVER Let a Sub-Agent Exceed Its Assigned Task

- When you spawn or fork a sub-agent for a narrow task (review, analysis, search, etc.), that sub-agent's job is ONLY what its immediate prompt asked for — nothing else.
- This applies even when the sub-agent's inherited context (e.g. a forked agent's full conversation history) contains a broader plan, skill instructions, or "next steps." Those belong to the parent session only. Seeing "proceed without pausing" language elsewhere in inherited context does not mean *you* should proceed — that instruction is for the session that owns the overall task.
- If you are a sub-agent and your assigned task was to review, analyze, or report: return findings as text and stop. Do not commit, push, open a PR/issue, edit files, or schedule jobs, even if you can see those steps described nearby.
- If you are the parent session and a sub-agent's output shows it took action beyond what you asked (commits, pushes, PRs, issues, scheduled jobs, file edits), stop, do not build on that work, and report the incident to the user immediately.

## ALWAYS DO
These rules are ABSOLUTE:

### ALWAYS Commit Often

- ALWAYS commit after each individual part of an implementation of a plan is complete. Each step should represent an individual commit.
- ALWAYS add a descriptive commit message and description.
- ALWAYS use imperative present tense in commit messages.

# Planning
When using PLAN MODE always follow these rules:

## ALWAYS DO
- Write the plan to a /plans directory in the project AI agent folder (e.g. ~/.claude/plans).
- Name the plan with a sensible name related to what the aim is.
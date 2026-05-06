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
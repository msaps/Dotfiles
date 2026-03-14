## Identities

## GitHub Account

**ALWAYS** use **msaps** for all projects:

- SSH: `git@github.com:msaps/<repo>.git`

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

## ALWAYS DO

These reules are ABSOLUTE:

### ALWAYS Commit Often

- ALWAYS commit after each individual part of an implementation of a plan is complete.
- ALWAYS add a descriptive commit message and description.
- ALWAYS use imperative present tense in commit messages.

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

## ALWAYS DO

- Commit often - commits should be small and well structured.
- Commit after each phase of a plan has been completed.

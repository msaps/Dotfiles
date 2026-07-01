---
name: issue-creator
description: Create a GitHub issue for the current repo with proper type classification (Feature, Enhancement, Bug) and structured body. Use when the user wants to log a new feature, improvement, or bug as a GitHub issue.
---

# Issue Creator

Create a well-structured GitHub issue for the current repository.

## Usage

```
/issue-creator [description]
```

Provide a brief description of what you want to log. If none is given, ask the user what they want to create an issue for.

## Process

### Step 1: Identify the Repository

```bash
gh repo view --json nameWithOwner,url
```

Confirm this is the correct repo. If the working directory is not a GitHub repo, stop and tell the user.

### Step 2: Classify the Issue Type

Based on the user's description, determine which type applies:

- **Feature** — something new being added to the project that does not exist yet.
- **Enhancement** — an improvement to something that already exists (behaviour, UX, performance, DX, etc.).
- **Bug** — something that is broken or not working as intended.

If the type is not clear from the description, ask the user directly before proceeding:

> "Is this a **Feature** (new capability), **Enhancement** (improvement to something existing), or **Bug** (something broken)?"

Do not guess if there is genuine ambiguity.

### Step 3: Gather Issue Details

Collect the information needed for the body. Ask the user for each field that was not already provided in their description. Be concise when asking — one question at a time if multiple fields are missing, or all at once if only one or two are needed.

#### Feature or Enhancement

- **Overview** — context for the issue: why we're doing it, relevant background, any constraints or decisions already made.
- **Goal** — the single clear outcome we want this issue to achieve.
- **Requirements** — a complete list of everything that must be done. Push for specifics; vague requirements make issues hard to close.

#### Bug

- **Problem** — what is broken, how it manifests, any error messages or reproduction steps.
- **Fix** — the proposed solution or approach (even if approximate).
- **Requirements** — a complete list of everything that needs to be done to close the issue.

### Step 4: Check for Existing Labels

```bash
gh label list --json name
```

Check whether labels matching `feature`, `enhancement`, and `bug` already exist. Note the exact casing/spelling for the type you need — GitHub label matching is case-sensitive with `gh issue create`.

If the required label does not exist, create it:

| Type        | Label        | Color   |
|-------------|--------------|---------|
| Feature     | `feature`    | `#0075ca` |
| Enhancement | `enhancement`| `#a2eeef` |
| Bug         | `bug`        | `#d73a4a` |

```bash
gh label create "feature" --color "#0075ca" --description "New capability"
gh label create "enhancement" --color "#a2eeef" --description "Improvement to existing functionality"
gh label create "bug" --color "#d73a4a" --description "Something is broken"
```

### Step 5: Compose the Issue Body

Construct the body using the details gathered in Step 3. Use the appropriate template:

#### Feature / Enhancement body

```markdown
## Overview

{overview}

## Goal

{goal}

## Requirements

- {requirement 1}
- {requirement 2}
- {requirement N}
```

#### Bug body

```markdown
## Problem

{problem}

## Fix

{fix}

## Requirements

- {requirement 1}
- {requirement 2}
- {requirement N}
```

### Step 6: Confirm Before Creating

Show the user a preview of the issue — title, type, and body — and ask for confirmation before creating it:

> "Ready to create this issue. Does it look right, or would you like to change anything?"

Do not create the issue until the user confirms. If they request changes, update the preview and confirm again.

### Step 7: Create the Issue

```bash
gh issue create \
  --title "{title}" \
  --body "$(cat <<'EOF'
{body}
EOF
)" \
  --label "{label}"
```

After creating, output the issue URL so the user can open it directly.

## Notes

- The issue title should be concise (under 70 characters) and written in imperative present tense (e.g. "Add dark mode support", "Fix crash on empty list", "Improve onboarding flow").
- Requirements should be specific enough that a developer can close each one unambiguously. If the user gives vague requirements, push back with a clarifying question.
- Do not add assignees, milestones, or projects unless the user explicitly requests them.
- Do not create the issue silently — always confirm with the user first.

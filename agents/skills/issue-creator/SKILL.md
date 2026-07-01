---
name: issue-creator
description: Create a GitHub issue for the current repo with proper type classification (Feature, Enhancement, Bug) and structured body. Use when the user wants to log a new feature, improvement, or bug as a GitHub issue.
---

# Issue Creator

Create a well-structured GitHub issue for the current repository.

## Usage

```
/issue-creator [description]
/issue-creator --auto --type <bug|enhancement|feature> --title "<title>" [fields]
```

**Interactive mode** (default): Converse with the user to gather missing fields, then create the issue.

**Auto mode** (`--auto`): All fields must be supplied upfront. No questions are asked. Fail immediately with a clear error if any required field is missing. Designed for autonomous agents and loops.

---

## Interactive Mode

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

### Step 4: Ensure Labels Exist

```bash
gh label list --json name
```

Create any missing labels:

```bash
gh label create "feature" --color "#0075ca" --description "New capability" 2>/dev/null || true
gh label create "enhancement" --color "#a2eeef" --description "Improvement to existing functionality" 2>/dev/null || true
gh label create "bug" --color "#d73a4a" --description "Something is broken" 2>/dev/null || true
```

### Step 5: Compose and Create the Issue

Construct the body from the gathered fields using the template for the issue type (see **Body Templates** below), then create:

```bash
gh issue create \
  --title "{title}" \
  --body "$(cat <<'EOF'
{body}
EOF
)" \
  --label "{label}"
```

Output the issue URL so the user can open it directly.

---

## Auto Mode

Invoked with `--auto`. All required fields must be present in the invocation — do not ask the user for anything.

### Required fields for all types

- `--type bug | enhancement | feature`
- `--title "<title>"`

### Additional required fields by type

**Bug**: `--problem`, `--fix`, `--requirements`

**Feature / Enhancement**: `--overview`, `--goal`, `--requirements`

### Validation

If any required field for the given type is missing, stop immediately and output:

```
[issue-creator] Auto mode error: missing required fields: <field>, <field>
```

Do not attempt to create the issue with incomplete data.

### Process

1. Parse all provided fields from the invocation.
2. Validate that every required field for the given type is present.
3. Ensure the label exists (same label creation commands as interactive mode).
4. Compose the body using the template for the issue type (see **Body Templates** below).
5. Create the issue immediately with no confirmation.
6. Output the issue URL.

---

## Body Templates

### Feature / Enhancement

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

### Bug

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

---

## Notes

- The issue title should be concise (under 70 characters) and written in imperative present tense (e.g. "Add dark mode support", "Fix crash on empty list", "Improve onboarding flow").
- Requirements should be specific enough that a developer can close each one unambiguously.
- Do not add assignees, milestones, or projects unless explicitly requested.
- Label mapping: Feature → `feature`, Enhancement → `enhancement`, Bug → `bug`.

---
name: issue-creator
description: Create a GitHub issue for the current repo with proper type classification (Feature, Task, Bug) set as a native Issue Type field (not a label), plus Effort and Priority evaluation. Use when the user wants to log a new feature, task, or bug as a GitHub issue.
---

# Issue Creator

Create a well-structured GitHub issue for the current repository.

## Usage

```
/issue-creator [description]
/issue-creator --auto --type <bug|task|feature> --title "<title>" [fields]
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

- **Feature** — something new being added to the project that brings new functionality.
- **Task** — a task that needs completing to improve or contribute to the project that does not directly bring new functionality.
- **Bug** — something that is broken or not working as intended.

If the type is not clear from the description, ask the user directly before proceeding:

> "Is this a **Feature** (new functionality), **Task** (improvement that brings no new functionality), or **Bug** (something broken)?"

Do not guess if there is genuine ambiguity.

### Step 3: Gather Issue Details

Collect the information needed for the body. Ask the user for each field that was not already provided in their description. Be concise when asking — one question at a time if multiple fields are missing, or all at once if only one or two are needed.

#### Feature or Task

- **Overview** — context for the issue: why we're doing it, relevant background, any constraints or decisions already made.
- **Goal** — the single clear outcome we want this issue to achieve.
- **Requirements** — a complete list of everything that must be done. Push for specifics; vague requirements make issues hard to close.

#### Bug

- **Problem** — what is broken, how it manifests, any error messages or reproduction steps.
- **Fix** — the proposed solution or approach (even if approximate).
- **Requirements** — a complete list of everything that needs to be done to close the issue.

### Step 4: Evaluate Effort and Priority (optional)

After gathering issue details, attempt to evaluate **Effort** and **Priority** from the full picture. These are best-effort — if there is not enough context to make a confident call, skip them rather than guessing. If you can derive one but not the other, only set the one you're confident about.

#### Effort (High / Medium / Low)

Assess the scope and complexity of the work:

- **Low** — small, well-scoped change; few requirements; no significant unknowns or dependencies.
- **Medium** — moderate scope; several requirements; some design decisions or unknowns.
- **High** — large scope; many requirements; complex dependencies, significant design work, or high uncertainty.

#### Priority (Urgent / High / Medium / Low)

Assess the impact and urgency of the issue:

- **Urgent** — blocking production or users, security vulnerability, or on the critical path to an imminent release.
- **High** — important near-term impact; blocks other work or affects many users.
- **Medium** — planned, valuable work that should be done but is not immediately blocking.
- **Low** — nice to have; low impact; can be deferred without consequence.

When you can make a confident call, present your evaluation briefly:

> "I'd classify this as **Medium effort** (a few well-defined requirements, no major unknowns) and **High priority** (it blocks other planned work). Does that sound right, or would you adjust either?"

If the user corrects either value, use their value. If you cannot confidently determine a value, omit it — do not add the label.

### Step 5: Ensure Effort and Priority Labels Exist

Only run this step if you have at least one confident Effort or Priority value to set.

```bash
gh label list --json name
```

Create any missing labels:

```bash
gh label create "effort:low"    --color "#c2e0c6" --description "Small, well-scoped change" 2>/dev/null || true
gh label create "effort:medium" --color "#fef2c0" --description "Moderate scope and complexity" 2>/dev/null || true
gh label create "effort:high"   --color "#f9d0c4" --description "Large scope or high complexity" 2>/dev/null || true

gh label create "priority:low"    --color "#e4e4e4" --description "Nice to have, low impact" 2>/dev/null || true
gh label create "priority:medium" --color "#bfd4f2" --description "Planned, valuable work" 2>/dev/null || true
gh label create "priority:high"   --color "#0075ca" --description "Important, near-term impact" 2>/dev/null || true
gh label create "priority:urgent" --color "#d73a4a" --description "Blocking or critical path" 2>/dev/null || true
```

### Step 6: Compose and Create the Issue

Construct the body from the gathered fields using the template for the issue type (see **Body Templates** below), then create the issue using the **native Issue Type field** (not a label) plus any derived effort and priority labels:

```bash
gh issue create \
  --title "{title}" \
  --type "{Feature|Task|Bug}" \
  --label "effort:{low|medium|high}" \       # omit if effort not determined
  --label "priority:{low|medium|high|urgent}" \  # omit if priority not determined
  --body "$(cat <<'EOF'
{body}
EOF
)"
```

Output the issue URL so the user can open it directly.

---

## Auto Mode

Invoked with `--auto`. All required fields must be present in the invocation — do not ask the user for anything.

### Required fields for all types

- `--type bug | task | feature`
- `--title "<title>"`

### Optional fields for all types

- `--effort low | medium | high`
- `--priority low | medium | high | urgent`

### Additional required fields by type

**Bug**: `--problem`, `--fix`, `--requirements`

**Feature / Task**: `--overview`, `--goal`, `--requirements`

### Validation

If any required field for the given type is missing, stop immediately and output:

```
[issue-creator] Auto mode error: missing required fields: <field>, <field>
```

Do not attempt to create the issue with incomplete data.

### Process

1. Parse all provided fields from the invocation.
2. Validate that every required field for the given type is present.
3. If `--effort` or `--priority` were supplied, ensure their labels exist (same label creation commands as interactive mode). If neither was supplied, skip label creation.
4. Compose the body using the template for the issue type (see **Body Templates** below).
5. Create the issue immediately with no confirmation using `--type` and any supplied `--label "effort:..."` / `--label "priority:..."` flags.
6. Output the issue URL.

---

## Body Templates

### Feature / Task

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
- Issue Type is set via `--type` (a native GitHub field), never as a label.
- Effort and Priority are set as labels (`effort:*`, `priority:*`) when they can be confidently determined — omit them otherwise.
- Do not add assignees, milestones, or projects unless explicitly requested.

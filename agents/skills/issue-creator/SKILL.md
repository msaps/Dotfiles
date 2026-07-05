---
name: issue-creator
description: Create a GitHub issue for the current repo with proper type classification (Feature, Task, Bug) set as a native Issue Type field (not a label), plus Effort and Priority set as native issue fields.
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

If the user corrects either value, use their value. If you cannot confidently determine a value, omit it.

### Step 5: Compose and Create the Issue

Construct the body from the gathered fields using the template for the issue type (see **Body Templates** below), then create the issue:

```bash
gh issue create \
  --title "{title}" \
  --type "{Feature|Task|Bug}" \
  --body "$(cat <<'EOF'
{body}
EOF
)"
```

Capture the issue URL output and extract the issue number from it.

### Step 6: Set Effort and Priority as Native Issue Fields

Only run this step if you have at least one confident Effort or Priority value to set.

Fetch the org's issue fields to get field IDs and option IDs:

```bash
OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO=$(gh repo view --json name --jq '.name')
gh api /orgs/$OWNER/issue-fields
```

From the response, find the `id` of the "Priority" and "Effort" fields, and the `id` of the matching option (e.g. "High", "Medium", "Low", "Urgent" — capitalised). If either field does not exist in the org, skip it silently.

Then post the field values to the created issue:

```bash
gh api --method POST "repos/$OWNER/$REPO/issues/{issue_number}/issue-field-values" \
  --input - <<'EOF'
{
  "issue_field_values": [
    {"issue_field_id": {priority_field_id}, "value": {priority_option_id}},
    {"issue_field_id": {effort_field_id}, "value": {effort_option_id}}
  ]
}
EOF
```

Omit either entry from `issue_field_values` if that field was not determined or does not exist in the org.

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
3. Compose the body using the template for the issue type (see **Body Templates** below).
4. Create the issue immediately with no confirmation using `--type`.
5. If `--effort` or `--priority` were supplied, set them as native issue fields (same API steps as interactive Step 6). If neither was supplied, skip.
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
- Effort and Priority are set as native issue fields via the API, never as labels.
- Do not add assignees, milestones, or projects unless explicitly requested.

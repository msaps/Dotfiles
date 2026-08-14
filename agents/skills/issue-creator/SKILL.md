---
name: issue-creator
description: Create a GitHub issue for the current repo with proper type classification (Feature, Task, Bug) set as a native Issue Type field (not a label), plus Effort and Priority set as native issue fields. Breaks complex work into a parent issue with native sub-issues when it doesn't fit as one unit of work.
---

# Issue Creator

Create a well-structured GitHub issue for the current repository. When the work is genuinely complex and decomposes into distinct chunks, create a parent tracking issue with native GitHub sub-issues instead of one oversized issue.

## Usage

```
/issue-creator [description]
/issue-creator --auto --type <bug|task|feature> --title "<title>" [fields]
```

**Interactive mode** (default): Converse with the user to gather missing fields, assess whether the work should be split into sub-issues, then create the issue(s).

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

### Step 4: Assess Whether This Should Be Sub-Issues

Look at the requirements list gathered in Step 3 and judge whether this is really **one unit of work** or several.

Lean toward splitting when most of these hold:

- The requirements span genuinely distinct areas (different components, layers, or concerns) rather than being sequential steps of one change.
- There are enough requirements (roughly 6+, or fewer if each is substantial) that a single issue would be hard to review or close as a unit.
- The parts could reasonably be worked on, reviewed, or shipped independently or by different people.
- Effort feels **High** largely because it's actually several mediums bundled together.

Keep it as a single issue when:

- The requirements are just the steps needed to complete one cohesive change.
- The parts are tightly coupled and don't make sense to review or merge separately.
- Effort is Low/Medium.
- The user has already described it as one focused piece of work.

Do not split reflexively — most issues should stay single. When genuinely unsure, default to a single issue.

If splitting looks right, propose it rather than deciding unilaterally:

> "This covers a few distinct areas — {A}, {B}, {C}. I'd suggest a parent tracking issue with a sub-issue for each, rather than one large issue. Want me to structure it that way, or keep it as a single issue?"

If the user agrees, group the gathered requirements into coherent sub-issues and, for each one, confirm or fill in a title and (if needed) any missing context specific to that part — reuse shared context from the parent's Overview/Problem rather than re-asking. Each sub-issue is classified with its own type (Step 2 categories) — a "Feature" parent can have "Task" or "Bug" sub-issues if that fits better.

If the user declines, proceed as a single issue.

### Step 5: Evaluate Effort and Priority (optional)

Attempt to evaluate **Effort** and **Priority** for each issue you're about to create (the single issue, or the parent plus every sub-issue). These are best-effort — if there is not enough context to make a confident call, skip them rather than guessing. If you can derive one but not the other, only set the one you're confident about.

#### Effort (High / Medium / Low)

Assess the scope and complexity of the work:

- **Low** — small, well-scoped change; few requirements; no significant unknowns or dependencies.
- **Medium** — moderate scope; several requirements; some design decisions or unknowns.
- **High** — large scope; many requirements; complex dependencies, significant design work, or high uncertainty.

For a parent tracking issue with sub-issues, Effort/Priority describe the rollup — e.g. Effort is usually High (it's several sub-issues' worth of work) even if each sub-issue individually is Low or Medium.

#### Priority (Urgent / High / Medium / Low)

Assess the impact and urgency of the issue:

- **Urgent** — blocking production or users, security vulnerability, or on the critical path to an imminent release.
- **High** — important near-term impact; blocks other work or affects many users.
- **Medium** — planned, valuable work that should be done but is not immediately blocking.
- **Low** — nice to have; low impact; can be deferred without consequence.

When you can make a confident call, present your evaluation briefly:

> "I'd classify this as **Medium effort** (a few well-defined requirements, no major unknowns) and **High priority** (it blocks other planned work). Does that sound right, or would you adjust either?"

If the user corrects either value, use their value. If you cannot confidently determine a value, omit it.

### Step 6: Compose and Create the Issue(s)

**Single issue:** Construct the body from the gathered fields using the template for the issue type (see **Body Templates** below), then create it:

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

**Parent + sub-issues:** Create the parent first, then each sub-issue linked to it via the native `--parent` flag.

1. Create the parent issue using the **Parent Issue** template (see **Body Templates** below):

   ```bash
   gh issue create \
     --title "{parent title}" \
     --type "{Feature|Task|Bug}" \
     --body "$(cat <<'EOF'
   {parent body}
   EOF
   )"
   ```

   Capture the parent's issue number from the output URL.

2. Create each sub-issue using the normal Feature/Task/Bug template, linked to the parent:

   ```bash
   gh issue create \
     --title "{sub-issue title}" \
     --type "{Feature|Task|Bug}" \
     --parent {parent_number} \
     --body "$(cat <<'EOF'
   {sub-issue body}
   EOF
   )"
   ```

   Capture each sub-issue's number.

`--parent` accepts either the bare issue number or its full URL and creates a native GitHub sub-issue relationship (not a label or checklist) — the parent's issue page will show a tracked sub-issue list automatically.

### Step 7: Set Effort and Priority as Native Issue Fields

Only run this step for issues where you have at least one confident Effort or Priority value to set (the single issue, and/or the parent and/or individual sub-issues).

Fetch the org's issue fields to get field IDs and option IDs:

```bash
OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO=$(gh repo view --json name --jq '.name')
gh api /orgs/$OWNER/issue-fields
```

From the response, find the `id` of the "Priority" and "Effort" fields. If either field does not exist in the org, skip it silently.

Then post the field values to each created issue in turn (parent and every sub-issue that has values to set). The `value` is the option **name as a string** (e.g. `"High"`, `"Medium"`, `"Low"`, `"Urgent"` — capitalised), and the key is `field_id` (not `issue_field_id`):

```bash
gh api --method POST "repos/$OWNER/$REPO/issues/{issue_number}/issue-field-values" \
  --input - <<EOF
{
  "issue_field_values": [
    {"field_id": {priority_field_id}, "value": "High"},
    {"field_id": {effort_field_id}, "value": "Medium"}
  ]
}
EOF
```

Omit either entry from `issue_field_values` if that field was not determined or does not exist in the org.

Output the issue URL (and, if sub-issues were created, the parent URL plus each sub-issue URL) so the user can open them directly.

---

## Auto Mode

Invoked with `--auto`. All required fields must be present in the invocation — do not ask the user for anything, and do not assess complexity yourself: only split into sub-issues if the caller explicitly supplies `--subissues`.

### Required fields for all types

- `--type bug | task | feature`
- `--title "<title>"`

### Optional fields for all types

- `--effort low | medium | high`
- `--priority low | medium | high | urgent`
- `--subissues '<JSON array>'` — when present, the top-level fields describe the **parent** issue and each array element describes one sub-issue. See **Sub-Issues in Auto Mode** below.

### Additional required fields by type

**Bug**: `--problem`, `--fix`, `--requirements`

**Feature / Task**: `--overview`, `--goal`, `--requirements`

### Validation

If any required field for the given type is missing, stop immediately and output:

```
[issue-creator] Auto mode error: missing required fields: <field>, <field>
```

If `--subissues` is present but fails to parse as JSON, or any element is missing its own required fields, stop immediately and output:

```
[issue-creator] Auto mode error: invalid --subissues entry <index>: missing required fields: <field>, <field>
```

Do not attempt to create any issue with incomplete data.

### Process

1. Parse all provided fields from the invocation.
2. Validate that every required field for the given type is present (and, if `--subissues` was passed, that every sub-issue entry is valid — same required-field rules as the top level, applied per entry's own `type`).
3. **No `--subissues`:** compose the body using the template for the issue type (see **Body Templates**), create the issue immediately with no confirmation using `--type`, set `--effort`/`--priority` as native fields if supplied, output the issue URL.
4. **With `--subissues`:** compose the parent body using the **Parent Issue** template, create the parent issue, then create each sub-issue in array order using its own `type`/title/body fields and `--parent {parent_number}`. Set Effort/Priority as native fields for the parent and for each sub-issue that supplied them. Output the parent URL followed by each sub-issue URL.

### Sub-Issues in Auto Mode

`--subissues` is a JSON array. Each element is an object with the same shape as the top-level auto-mode fields, minus `--auto`/`--subissues` themselves:

```json
[
  {
    "type": "task",
    "title": "Add database migration for widgets table",
    "overview": "...",
    "goal": "...",
    "requirements": ["...", "..."],
    "effort": "low",
    "priority": "medium"
  },
  {
    "type": "feature",
    "title": "Expose widgets in the API",
    "overview": "...",
    "goal": "...",
    "requirements": ["...", "..."]
  }
]
```

Bug-type entries use `"problem"` and `"fix"` instead of `"overview"` and `"goal"`, matching the top-level Bug fields. `effort`/`priority` are optional per entry.

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

### Parent Issue

Used only when work is split into sub-issues. Same shape as the Feature/Task or Bug template, but `Requirements` is replaced with a rollup list of the sub-issues for readability anywhere the native sub-issue UI isn't visible (e.g. terminal, API) — GitHub still tracks the real relationship natively via `--parent`, this list is a convenience summary, not the source of truth.

```markdown
## Overview

{overview}

## Goal

{goal}

## Sub-Issues

- {sub-issue 1 title}
- {sub-issue 2 title}
- {sub-issue N title}
```

For a Bug-type parent, use `## Problem` / `## Fix` in place of `## Overview` / `## Goal`.

---

## Notes

- Whenever a class name or type name is referenced in an issue title or body (e.g. `UserSession`, `ViewController`, `WidgetRepository`), wrap it in backticks so it renders as inline code. This applies to titles, overview/problem/goal text, and requirements — everywhere a type name appears, including in sub-issue titles and bodies.
- The issue title should be concise (under 70 characters) and written in imperative present tense (e.g. "Add dark mode support", "Fix crash on empty list", "Improve onboarding flow").
- Requirements should be specific enough that a developer can close each one unambiguously.
- Issue Type is set via `--type` (a native GitHub field), never as a label.
- Effort and Priority are set as native issue fields via the API, never as labels.
- Sub-issues are created via `gh issue create --parent`, a native GitHub relationship — never simulate them with labels, checklists, or issue-title prefixes.
- Splitting into sub-issues is the exception, not the default — most issues should stay single. Only split when the work genuinely decomposes into independent chunks (see Step 4).
- Do not add assignees, milestones, or projects unless explicitly requested.

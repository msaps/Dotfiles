---
name: issue-creator
description: Create a well-scoped GitHub issue with a native Feature, Task, or Bug type, optional native Effort and Priority fields, and native sub-issues when work genuinely decomposes. Use when the user asks to file, draft, or create GitHub issues.
---

# Create a GitHub Issue

Create clear, testable issues in the current repository. Never include credentials, private tokens, or sensitive raw logs in an issue.

## Inputs and modes

Interactive mode is the default. Use the user's description, ask only for material missing details, and create after the issue is concrete.

Automatic mode is selected by `--auto` and is intended for another trusted workflow. It must validate all supplied fields and create without questions. For its accepted fields and validation contract, read [references/auto-mode.md](references/auto-mode.md).

## Classify and define the issue

1. Confirm `gh repo view` and `gh auth status` succeed.
2. Choose the native issue type:

   - `Feature`: new user-facing or product functionality.
   - `Task`: maintenance, infrastructure, design, or improvement work without new product functionality.
   - `Bug`: behavior that is broken or contradicts its intended contract.

   Ask when the distinction is genuinely ambiguous.

3. Gather the fields the user has not already supplied:

   - Feature or Task: overview, one outcome-oriented goal, and testable requirements.
   - Bug: observable problem and reproduction evidence, proposed fix or direction, and testable requirements.

4. Draft an imperative title under 70 characters. Wrap code identifiers such as class and type names in backticks throughout the title and body.

## Decide whether to split

Keep most work as one issue. Propose a parent with native sub-issues only when the work spans independently implementable or reviewable areas and the combined issue would be difficult to close as one unit. Sequential steps of one cohesive change are not separate issues.

In interactive mode, get the user's agreement before splitting. In automatic mode, split only when valid `--subissues` data was supplied. Give each child its own type, context, goal or fix, and requirements; do not copy vague parent text into every child.

## Effort and priority

Set these only when they can be judged confidently, and let an explicit user value win:

- Effort: `Low`, `Medium`, or `High`, based on scope, dependencies, design work, and uncertainty.
- Priority: `Low`, `Medium`, `High`, or `Urgent`, based on impact and time sensitivity. Reserve `Urgent` for production/user blocking, serious security, or an imminent critical path.

In interactive mode, briefly present inferred values for correction. When at least one value should be set, read [references/native-fields.md](references/native-fields.md) before creating or updating field values.

## Create

1. Render bodies in one of these forms:

   ```markdown
   ## Overview

   <context and constraints>

   ## Goal

   <single outcome>

   ## Requirements

   - <testable requirement>
   ```

   ```markdown
   ## Problem

   <observable behavior, evidence, and impact>

   ## Fix

   <proposed correction>

   ## Requirements

   - <testable requirement>
   ```

2. Write each body to a temporary file and call `gh issue create --title ... --type ... --body-file ...`. Do not interpolate a body directly into a shell command.
3. For split work, create the parent first and each child with `--parent <parent-number>`. Give the parent a `## Sub-Issues` rollup, but rely on GitHub's native relationship as the source of truth.
4. Apply confident Effort and Priority values as native fields. Never substitute labels for Issue Type, Effort, Priority, or sub-issue relationships.
5. Return every created URL and the selected type and field values. Do not add assignees, milestones, projects, or labels unless explicitly requested.

If GitHub does not expose a requested native issue type or field, report that limitation. Do not silently degrade to a label.

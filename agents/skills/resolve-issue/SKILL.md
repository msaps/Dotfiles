---
name: resolve-issue
description: Resolve a GitHub issue end-to-end — understand the issue, evaluate the codebase, plan the implementation, write production-quality code with tests, review and fix, then open a pull request.
---

# Resolve Issue

Fully resolve a GitHub issue from first read to open pull request.

## Usage

```
/resolve-issue <issue-number>
```

`<issue-number>` is required. This is the GitHub issue number to resolve.

---

## Process

### Step 1: Load the Issue

```bash
gh repo view --json nameWithOwner,url
gh issue view <issue-number> --json number,title,body,labels,comments
```

Read the issue title, body, all labels, and every comment thread. Treat comments as part of the specification — they often contain clarifications, corrections, or additional requirements that override the original body.

Identify and record:
- **Type**: bug fix, feature, enhancement, or task
- **Goal**: the single clear outcome this issue wants to achieve
- **Requirements**: every discrete thing that must be done to close the issue
- **Constraints**: anything explicitly out of scope or disallowed

If the issue body is empty or the goal is genuinely unclear, stop and report the blocker. Do not proceed with an ambiguous goal.

### Step 2: Survey the Codebase

Explore the repository to understand the areas of code relevant to this issue. Cover:

1. **Entry points** — identify relevant files, modules, or components that will need to change
2. **Existing tests** — locate the test suite structure and any existing tests for the affected code
3. **Conventions** — note the project's style (naming, error handling, test patterns, documentation conventions)
4. **Dependencies** — identify any libraries, APIs, or shared utilities involved

Use `find`, `grep`, and `Read` freely — build a clear mental model before writing any code.

### Step 3: Analyse Gaps and Discrepancies

Before planning, compare the issue requirements against the current codebase:

- **Missing functionality** — required behaviour that does not exist yet
- **Broken behaviour** — existing code that contradicts the issue's requirements
- **Ambiguities** — requirements that are underspecified or have multiple valid interpretations
- **Scope creep risks** — adjacent problems visible in the codebase that are not part of this issue (note them, but do not address them here)
- **Blocked requirements** — anything that cannot be implemented without a decision or dependency that is not yet resolved

If any gaps or ambiguities would materially change the implementation approach, log a brief summary of the interpretation chosen and proceed. Do not stop for confirmation.

### Step 4: Create the Implementation Plan

Write a structured plan covering every requirement from the issue. Save it to the plans directory:

```
~/.claude/plans/issue-<number>-<short-slug>.md
```

The plan must contain:

```markdown
# Issue #<number>: <title>

## Goal

<single clear outcome>

## Requirements

- [ ] <requirement 1>
- [ ] <requirement 2>
- [ ] <requirement N>

## Implementation Steps

### 1. <Step name>
<What to change and why. Name specific files and functions.>

### 2. <Step name>
...

## Test Plan

<How correctness will be verified. Name specific test files and describe what each new test covers.>

## Out of Scope

<Anything explicitly not being done here.>
```

Log a one-paragraph summary of the plan before proceeding to implementation. Do not wait for confirmation — proceed immediately.

### Step 5: Create a Feature Branch

Branch off the default branch using a name derived from the issue:

```bash
git fetch origin
git checkout -b feature/issue-<number>-<short-slug> origin/$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
```

Use a short kebab-case slug (3–5 words max) that describes the issue, not the implementation.

### Step 6: Implement the Plan

Work through the plan step by step. For each step:

1. Read all files that will be changed before editing them
2. Make only the changes required by this step — do not refactor unrelated code
3. Write tests alongside the implementation (see **Testing Standards** below)
4. Verify the change compiles / lints cleanly if a check command is available
5. Commit immediately after each step completes:

```bash
git add <specific files>
git commit -m "$(cat <<'EOF'
<imperative present-tense summary under 70 chars>

<optional one-paragraph body explaining the why>

Resolves #<number>
EOF
)"
```

Never batch multiple steps into one commit. Each commit should be independently coherent.

#### Testing Standards

- Add tests for every new behaviour introduced
- Add a regression test for every bug fixed (a test that fails before the fix and passes after)
- Follow the existing test style, framework, and file structure exactly
- Do not delete or weaken existing tests to make new code pass
- If no test suite exists, note this explicitly and add tests in whatever pattern fits the project type

### Step 7: Push the Branch

After all commits are complete:

```bash
git push -u origin HEAD
```

### Step 8: Run Code Review

Invoke the code review skill at high effort against the branch diff:

```
/code-review high
```

Read every finding carefully. Categorise each one:

- **Must fix** — correctness bug, security issue, test gap, or clear logic error
- **Should fix** — code quality issue that is non-trivial and worth addressing before merge
- **Defer** — style preference, speculative concern, or out-of-scope improvement

### Step 9: Resolve Review Findings

For each **must fix** and **should fix** finding:

1. Make the change
2. Commit immediately with a message referencing what it addresses (e.g. "Fix off-by-one in pagination boundary check")
3. Push after all fixes are committed:

```bash
git push
```

Re-run a quick sanity check after fixes:

```
/code-review low
```

Confirm no new issues were introduced.

#### Raise Issues for Deferred Findings

For every finding categorised as **defer**, and for every **should fix** finding that was not addressed (e.g. out of scope, risk too high to take before merge), create a GitHub issue immediately using `issue-creator` in auto mode. Do not skip any — every surfaced concern must either be fixed or tracked.

Map finding categories to issue types:
- Code quality, design concern, or improvement → `--type enhancement`
- Correctness risk not blocking this PR → `--type bug`

For each deferred finding, invoke:

```
/issue-creator --auto \
  --type enhancement \
  --title "{concise imperative title}" \
  --overview "Surfaced during code review of PR resolving issue #<number>. {description of the finding and why it was deferred}" \
  --goal "{what resolving this issue would achieve}" \
  --requirements "{list of specific things to do}"
```

Or for a deferred correctness concern:

```
/issue-creator --auto \
  --type bug \
  --title "{concise imperative title}" \
  --problem "{what is wrong and how it manifests}" \
  --fix "{proposed approach}" \
  --requirements "{list of specific things to do}"
```

Collect the URL of each created issue.

### Step 10: Open the Pull Request

Invoke the PR creation skill:

```
/pr-create
```

The PR description must include:

- A **Summary** section: 2–4 bullet points covering what changed and why
- A **Test plan** section: what tests were added and how to verify the change manually if applicable
- `Closes #<number>` on its own line so the issue auto-closes on merge
- A **Follow-up issues** section listing the URL of each issue created from deferred review findings (omit section entirely if none)

---

## Notes

- Never commit directly to `main` or the default branch. Always use a `feature/issue-<number>-*` branch.
- Never force-push.
- Do not address issues or improvements beyond the scope of the target issue. Note them but leave them for separate issues.
- If CI is configured, check `gh pr checks` after opening the PR and report the result. Do not merge — that is the human's decision.
- If the issue is already closed, stop and report — do not reopen or implement silently.
- If the issue is assigned to someone else, proceed normally — the skill does not gate on assignment.
- This skill is designed to run headlessly. Do not pause for confirmation at any point except when the issue goal is genuinely ambiguous or a hard blocker is encountered.

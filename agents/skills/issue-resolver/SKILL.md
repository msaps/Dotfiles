---
name: issue-resolver
description: Resolve a GitHub issue end-to-end — understand the issue, evaluate the codebase, plan the implementation, write production-quality code with tests, review and fix, then open a pull request.
---

# Resolve Issue

Fully resolve a GitHub issue from first read to open pull request.

## Usage

```
/issue-resolver <issue-number>
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

Immediately assign yourself to the issue:

```bash
gh issue edit <issue-number> --add-assignee @me
```

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

### Step 5: Prepare the Workspace

Before writing any code, isolate the work in a worktree on a fresh branch cut from the latest default branch. Use a short kebab-case slug (3–5 words max) that describes the issue, not the implementation — reuse the same slug chosen for the plan file in Step 4.

1. **Enter a worktree, if not already in one.** Check whether the session is already inside a worktree (e.g. you were invoked from within `.claude/worktrees/*`, or a prior `EnterWorktree` call already succeeded this session). If not, create one scoped to this issue:

   ```
   EnterWorktree(name: "issue-<number>-<short-slug>")
   ```

   With the default `worktree.baseRef` setting (`fresh`), this branches from `origin/<default-branch>` — which also satisfies "pull the latest changes from main." If `EnterWorktree` is unavailable (e.g. running outside the harness), fall back to plain git:

   ```bash
   git fetch origin
   git worktree add ../issue-<number>-<short-slug> -b feature/issue-<number>-<short-slug> origin/$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
   cd ../issue-<number>-<short-slug>
   ```

2. **If already in a worktree**, don't create a new one — instead bring the existing one up to date with the default branch:

   ```bash
   git fetch origin
   git merge --ff-only origin/$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')
   ```

3. **Ensure the branch is named correctly.** Regardless of which path above was taken, the working branch must end up named `feature/issue-<number>-<short-slug>`:

   ```bash
   git branch -m feature/issue-<number>-<short-slug>
   ```

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

Choose the review effort level based on the scope of changes:

| Effort | When to use |
|--------|-------------|
| `low`  | Single-file bug fixes, trivial additions, <50 lines changed |
| `medium` | Multi-file changes, small features, 50–200 lines changed |
| `high` | Cross-cutting changes, new subsystems, complex logic, >200 lines changed |
| `max`  | Security-sensitive code, payment flows, auth, data migrations, or anything where a missed bug would have serious consequences |

Then invoke the code review skill at the chosen effort level:

```
/code-review <effort>
```

Read every finding carefully. Categorise each one:

- **Must fix** — correctness bug, security issue, test gap, or clear logic error
- **Should fix** — code quality issue that is non-trivial and worth addressing before merge
- **Defer** — style preference, speculative concern, or out-of-scope improvement

Record the full categorised list before proceeding — you will need it in Steps 9 and 10.

### Step 9: Resolve Review Findings

For each **must fix** and **should fix** finding:

1. Make the change
2. Commit immediately with a message referencing what it addresses (e.g. "Fix off-by-one in pagination boundary check")
3. Push after all fixes are committed:

```bash
git push
```

Then do a quick self-review: run `git diff HEAD~<n>..HEAD` (where `<n>` is the number of fix commits) and read every changed line. Check only for obvious mistakes introduced by the fixes (syntax errors, wrong variable names, missing returns). Do **not** run `/code-review` again — it will return empty output and cause a stall.

Log one sentence: either "Self-review clean." or "Found X in Y — fixing now." Fix any problems found, commit, and push. Then **proceed immediately to Step 10** without pausing or waiting for input.

### Step 10: Raise Issues for Deferred Findings

This step is **mandatory** even when there are zero deferred findings — in that case, simply note "No deferred findings; skipping." and continue to Step 11.

**Default: fix it, don't defer it.** Before creating a deferred issue for any finding, ask: can this be addressed in the current PR without meaningful scope creep or risk? If yes, fix it and commit. A finding should only become a deferred issue if it meets one of these criteria:
- It requires changes in a different area of the codebase that would significantly expand the PR scope
- It is genuinely out of scope for the target issue (e.g. a pre-existing problem unrelated to the change)
- Fixing it now would introduce meaningful risk to the PR (e.g. requires a design decision, architectural change, or data migration)
- It is a speculative concern with no clear right answer at this point

Style preferences and minor nitpicks that can be addressed in-line should be fixed immediately, not deferred.

For the remaining findings that genuinely cannot be fixed in this PR, create a GitHub issue using the `issue-creator` skill in auto mode. Invoke it with the `Skill` tool (skill name: `issue-creator`). Every surfaced concern must either be fixed or tracked.

Classify each finding as one of:
- **bug** — something is broken or incorrect
- **task** — an improvement, quality concern, or design issue that is not a defect

Pass the following args to the `issue-creator` skill for a deferred bug:

```
--auto --type bug --title "{concise imperative title}" --problem "{what is wrong and how it manifests}" --fix "{proposed approach}" --requirements "{list of specific things to do}"
```

For a deferred task:

```
--auto --type task --title "{concise imperative title}" --overview "Surfaced during code review of PR resolving issue #<number>. {description of the finding and why it was deferred}" --goal "{what resolving this issue would achieve}" --requirements "{list of specific things to do}"
```

Collect the URL of each created issue. When all deferred issues are created (or when none exist), **proceed immediately to Step 11**.

### Step 11: Open the Pull Request

Invoke the PR creation skill:

```
/pr-create
```

The PR description must include:

- A **Summary** section: 2–4 bullet points covering what changed and why
- A **Test plan** section: what tests were added and how to verify the change manually if applicable
- `Closes #<number>` on its own line so the issue auto-closes on merge
- A **Follow-up issues** section listing the URL of each issue created from deferred review findings (omit section entirely if none)

Record the PR number and the `owner/repo` slug — Step 12 needs both.

### Step 12: Wait for Merge, Then Clean Up

Do not sit in this session polling for merge status — that burns tokens for no reason. Instead, hand the wait off to a lightweight recurring cron check.

1. Schedule a poll, off the exact half-hour so it doesn't collide with everyone else's cron jobs:

```
CronCreate(
  cron: "12,42 * * * *",
  recurring: true,
  prompt: "Run `gh pr view <pr-number> --repo <owner>/<repo> --json state,mergedAt`. If mergedAt is set: use CronList to find this job's own id and CronDelete it, then call ExitWorktree(action: 'remove') to delete the worktree and branch, then report the PR merged and the worktree was cleaned up. If state is CLOSED and mergedAt is null: CronDelete this job and report the PR was closed without merging — leave the worktree in place untouched. Otherwise (still OPEN): do nothing and let the job fire again later."
)
```

Substitute the actual PR number and `owner/repo` recorded in Step 11.

2. Tell the user the check is scheduled and will fire roughly every 30 minutes. Note the built-in limit: `CronCreate` recurring jobs auto-expire after 7 days. If the PR is still open at that point, the job stops firing and the worktree will need manual cleanup — mention this so it isn't a silent surprise.

3. This is the natural end of the skill's automated work for this issue. Nothing further happens synchronously; the merge check and cleanup complete asynchronously via the scheduled job.

---

## Notes

- Never commit directly to `main` or the default branch. Always use a `feature/issue-<number>-*` branch inside its own worktree (see Step 5).
- Never force-push.
- Do not call `ExitWorktree` yourself before Step 12 confirms the PR merged. Cleanup happens automatically once the scheduled check in Step 12 detects the merge.
- Do not address issues or improvements beyond the scope of the target issue. Note them but leave them for separate issues.
- If CI is configured, check `gh pr checks` after opening the PR and report the result. Do not merge — that is the human's decision.
- If the issue is already closed, stop and report — do not reopen or implement silently.
- If the issue is assigned to someone else, proceed normally — the skill does not gate on assignment.
- This skill is designed to run headlessly. Do not pause for confirmation at any point except when the issue goal is genuinely ambiguous or a hard blocker is encountered.

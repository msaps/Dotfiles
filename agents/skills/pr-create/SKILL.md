---
name: pr-create
description: Create a GitHub pull request from the current feature branch, with a complete branch-level summary and optional squash auto-merge. Use when the user asks to open or create a PR.
---

# Create a Pull Request

Create a pull request for the current branch. Inspect the complete branch, preserve the user's work, and return the PR URL.

Use the `gh` CLI for every GitHub interaction (reading, commenting, reviewing, merging), including `gh api` for endpoints without a dedicated subcommand. Never use a GitHub connector, app integration, or MCP/plugin tool, even if one is available.

## Preflight

1. Read `git status --short`, the current branch, remotes, and the repository's default branch from `gh repo view --json defaultBranchRef,nameWithOwner`.
2. Compare the whole branch with the default branch using both the commit log and three-dot diff.
3. Stop if the working tree has uncommitted changes, the current branch is the default branch, or the branch has no commits or diff to submit.
4. Confirm `gh auth status` succeeds.
5. Before any push, verify no `.env` file or likely credential is included in the branch diff. Never publish credentials.

## Create the PR

1. Draft an imperative title under 72 characters. Wrap code identifiers such as class or type names in backticks.
2. Draft a body with these sections:

   ```markdown
   ## Summary

   Briefly explain the outcome and why it matters.

   ## Changes

   - Describe the material changes across the full branch.

   ## Testing

   - List checks that were run, or state that testing was not performed.
   ```

3. Push the current branch, using `git push -u origin HEAD` when it has no upstream.
4. Create the PR non-interactively with the detected base branch and a temporary body file.
5. Attempt `gh pr merge --auto --squash` unless the user opted out. Never use `--admin` and never run a non-auto merge. If squash auto-merge is unsupported, try another repository-supported strategy only with `--auto`; otherwise report that auto-merge is unavailable.

## Finalization

By default, hand the new PR to a sub-agent that runs the `pr-finalize` skill in a watch loop until a stop condition is met. Skip finalization when the user passes `--skip-finalization` (or says so in words, such as "don't finalize"), or when auto-merge was opted out or is unavailable, because nothing would merge the PR. In those cases report that finalization was skipped and stop.

### Handoff

1. Capture the PR URL and number, then spawn one sub-agent in the background if the client supports it. If it does not, run the same loop inline after reporting the PR URL.
2. Give the sub-agent only this task: invoke `pr-finalize` for the PR and run the watch loop below. It must not merge, approve, force-push, bypass protections, or do anything else.
3. Return the normal Result to the user without waiting, noting that finalization is running.

### Watch loop

Repeat until a stop condition is met:

1. Read the PR state, review decision, mergeability, checks, review and comment counts, and head SHA with `gh`.
2. Evaluate the stop conditions and exit if one applies.
3. If there is new feedback or a failing check, run `pr-finalize` and count it as activity.
4. Wait for the current poll interval, then repeat.

Activity is any new commit, review, review comment or issue comment, any check status or conclusion change, or any change in review decision or mergeability.

### Stop conditions

| Condition | Report |
| --- | --- |
| PR merged | Merged, with what was addressed |
| PR closed without merge | Closed |
| PR approved with no unresolved feedback | Approved and merge-ready, noting whether auto-merge is still pending |
| `pr-finalize` reports a blocked conclusion | Blocked, with the reason and what is needed |
| 15 minutes with no activity | Idle timeout, with the last known state |

### Poll interval

Start at 30 seconds, then back off to 60, 120, 240, and a cap of 300 seconds. Reset to 30 seconds on any activity. Use the client's supported wait mechanism and never busy-loop.

### Final report

Return the PR URL, stop reason, number of `pr-finalize` passes, commits pushed, threads resolved or left open, and final CI state.

## Result

Return the PR URL, base branch, title, checks performed, and auto-merge status. If a command fails, return the actionable error instead of guessing.

---
name: pr-create
description: Create a GitHub pull request from the current feature branch, with a complete branch-level summary and optional squash auto-merge. Use when the user asks to open or create a PR.
---

# Create a Pull Request

Create a pull request for the current branch. Inspect the complete branch, preserve the user's work, and return the PR URL.

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

## Result

Return the PR URL, base branch, title, checks performed, and auto-merge status. If a command fails, return the actionable error instead of guessing.

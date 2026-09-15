---
name: git-cleanup
description: Remove local Git branches and worktrees that are verifiably no longer in use, after confirming each one is merged or abandoned and has no uncommitted or unpushed work. Designed to run unattended (headless, no approval prompts) using only safe, non-forcing Git commands. Use when the user asks to clean up, prune, or tidy old branches, worktrees, or both in a repository.
---

# Git Branch and Worktree Cleanup

Delete only what is provably safe to delete. This skill is meant to run
headless — with nobody available to confirm a risky deletion — so every
removal must be backed by verification, not by a guess like "looks old."
When a branch or worktree cannot be verified safe, skip it and report why
instead of asking for permission.

Never use forcing flags (`git branch -D`, `git worktree remove --force`,
`git push`). The safe equivalents (`git branch -d`, `git worktree remove`)
already refuse to act on unmerged or dirty state — lean on that as a second
safety net, not just on this skill's own checks.

## Scope

- Operate on the repository at the current working directory (or a path the
  user names). If it is not a Git repository, stop.
- Only touch local branches and local worktrees. Never delete a remote
  branch or push anything; the only remote interaction is fetching and
  pruning stale remote-tracking refs.
- If invoked with `--dry-run` (or the user only asks to "check" or "preview"
  what's stale), report the exact same verification results without
  deleting anything.

## Preflight

1. Confirm `git rev-parse --is-inside-work-tree` succeeds; stop otherwise.
2. Run `git fetch --all --prune` so remote-tracking refs and "gone" upstream
   state are current before any decision is made.
3. Resolve the default branch (`origin/HEAD` via
   `git symbolic-ref refs/remotes/origin/HEAD`, falling back to `main` or
   `master` if no remote is configured) and treat it as protected.
4. Build a protected set: the default branch, the branch checked out in
   every existing worktree (including the main one), and any branch matching
   a common long-lived pattern already protected elsewhere in this
   repository's tooling (e.g. `main`, `master`, `develop`). Never delete
   anything in this set.
5. List everything up front:
   - `git branch --list` (local branches) with each branch's upstream and
     ahead/behind/gone status via `git for-each-ref --format='%(refname:short) %(upstream:short) %(upstream:track)' refs/heads`.
   - `git worktree list --porcelain` (path, HEAD, branch, `locked`,
     `prunable`).

## Verify worktrees

For each worktree that is not the main working tree:

1. If its path no longer exists on disk, it is already prunable — run
   `git worktree prune -v` once for all of these rather than handling them
   individually.
2. If `git worktree list --porcelain` marks it `locked`, skip it and report
   the lock reason. Never unlock or force through a lock.
3. If the path exists, run `git -C <path> status --porcelain` (and check for
   an in-progress rebase/merge/cherry-pick via files under `.git`). Any
   output, or an in-progress operation, means real work is present — skip it.
4. Only if the worktree is clean does its branch become a deletion
   candidate; verify that branch with the same rules as below before
   removing anything.
5. Remove a verified worktree with `git worktree remove <path>` (no
   `--force`). If Git refuses, trust it and skip.

## Verify branches

A local branch is a deletion candidate only if **all** of the following
hold:

- It is not in the protected set (default branch, any branch checked out in
  a worktree, current branch).
- Its worktree (if any) was already verified clean and removed above.
- Either:
  - it is fully merged into the default branch
    (`git branch --merged <default>` includes it, or
    `git log <default>..<branch> --oneline` is empty), **or**
  - its upstream is reported `[gone]` (deleted on the remote) **and** it has
    no commits that are not also reachable from the default branch (same
    empty-log check) — a branch whose remote was deleted but which still
    carries unique local commits is not safe, it is orphaned work.
- It has no stash entries referencing it and is not the branch a stash was
  created from, if that's easy to check; when in doubt, skip.

If a branch fails any check, leave it and record the specific reason
(unmerged, has unique commits, upstream still active, locked worktree,
dirty worktree, protected). Do not delete "probably stale" branches based on
last-commit age alone — age is not evidence of safety by itself and is not a
deletion criterion here.

## Execute

1. Skip this whole section if running in dry-run/preview mode — report only.
2. Remove verified worktrees first (`git worktree remove <path>`), since a
   branch checked out in a worktree cannot be deleted.
3. Delete verified branches with `git branch -d <branch>` (never `-D`). If it
   fails, Git found something this skill's checks missed — skip and report
   the error rather than escalating to a force delete.
4. Run `git worktree prune -v` to clear administrative state for any
   already-missing worktree directories found during preflight.

## Report

Summarize, grouped by outcome:

- Removed worktrees (path, branch) and removed branches.
- Skipped worktrees/branches with the specific reason each was not
  verifiably safe.
- Anything that failed unexpectedly (e.g. `git branch -d` refused despite
  passing this skill's checks) — surface the raw Git error.

Keep the report factual and short; this skill's job is cleanup, not
narration.

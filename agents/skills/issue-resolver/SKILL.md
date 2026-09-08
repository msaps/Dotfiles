---
name: issue-resolver
description: Resolve a GitHub issue end-to-end by reading the full issue, planning, implementing and testing on a feature branch, reviewing the result, and opening a pull request. Use when the user asks to implement or resolve a specific issue.
---

# Resolve a GitHub Issue

Take a specific issue number or URL from specification through an open pull request. Stay within the issue's scope and preserve unrelated user work.

## Understand the issue

1. Resolve the repository and read the issue title, body, labels, state, assignees, and all comments. Stop if it is closed or its goal remains materially ambiguous after reading the discussion.
2. Assign the current GitHub user with `gh issue edit --add-assignee @me`.
3. Record the outcome, requirements, constraints, and explicit exclusions. Comments override stale text in the original body when they clearly clarify it.
4. Survey the relevant implementation, tests, conventions, and dependencies. Note adjacent problems without expanding scope.

## Plan and isolate

Write a focused plan to `~/.agents/plans/issue-<number>-<slug>.md` with the goal, requirement checklist, file-level implementation steps, test plan, and out-of-scope items. Continue without waiting for approval unless a missing decision would materially change the product behavior.

Work on a fresh `feature/issue-<number>-<slug>` branch based on the latest remote default branch. Use the host's isolated-worktree capability when available. Otherwise create a Git worktree with `git worktree add` and run all subsequent commands in it. If the session already has an isolated worktree, update that worktree and rename its branch instead of nesting another one.

Never modify the user's original checkout to simulate isolation, and never discard local changes.

## Implement

For each coherent plan step:

1. Read every affected file before editing.
2. Make only the required production and test changes.
3. Run the narrowest meaningful formatter, linter, build, or test checks.
4. Verify no credential or `.env` file is included.
5. Commit the completed step immediately with an imperative summary and a useful body. Append `Resolves #<number>` without amending earlier commits.

Add meaningful coverage for new behavior and a regression test for a bug when the repository has a relevant test framework. Do not add hollow tests that only mirror the implementation, and do not weaken existing tests.

## Review and finish

1. Review the aggregate diff against the default branch. For substantial or risk-sensitive changes, delegate one or more bounded read-only reviews when the host supports it. Delegated reviewers return findings only and must not edit, commit, push, create issues, or post comments.
2. Fix every correctness, security, or justified test finding in new commits. Address worthwhile in-scope quality findings; leave speculative or unrelated findings alone.
3. Create follow-up issues through `issue-creator` only for confirmed work that cannot safely fit this PR. Do not create issues merely to clear a review list.
4. Run the appropriate final checks, inspect the final diff, and push the feature branch.
5. Use the `pr-create` skill to open the pull request. Include `Closes #<number>` and any genuine follow-up issue URLs in its body.
6. Report the PR URL, commits, tests, review outcome, and remaining external blockers such as failing CI. Do not merge the PR or schedule monitoring unless the user explicitly requests that additional work.

If any delegated agent exceeds its assignment, stop immediately and report the incident without building on its changes.

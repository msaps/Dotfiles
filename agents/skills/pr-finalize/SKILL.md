---
name: pr-finalize
description: Address outstanding GitHub pull-request feedback, commit and push required fixes, reply to comments, resolve completed threads, and report merge readiness. Use when the user asks to finalize or respond to review feedback on a PR.
---

# Finalize a Pull Request

Process all outstanding feedback on a PR without approving or merging it.

## Load context safely

1. Resolve the PR number from the user's input or current branch. Read its state, title, URL, base, head branch and repository, head SHA, checks, reviews, and mergeability.
2. Stop if the PR is not open or if its head branch is the default branch.
3. Preserve unrelated local work. Use the existing checkout only when it is clean and already on the PR head branch; otherwise use an isolated worktree or stop if safe isolation is unavailable.
4. Fetch all review threads, including resolved state and comment IDs, plus issue-level comments and relevant bot or CI output.

## Triage

Classify each item as:

- code change required;
- reply required;
- bot or CI signal requiring investigation but no direct reply;
- already addressed or informational.

Do not dismiss substantive feedback. Leave genuinely ambiguous or out-of-scope requests open and explain the blocker rather than guessing.

## Address feedback

1. For each logical group of required changes, understand the affected code, implement the smallest correct fix, add or update meaningful tests, run focused checks, and commit immediately with an imperative message.
2. Before pushing, review the session's diff and verify no secret or `.env` file is included. Push once after all fix commits are ready.
3. Reply concisely to every human comment that was addressed or asked a question. Reply to a line comment through its reply endpoint and to an issue-level comment through the issue comments endpoint. Do not reply to automated status messages.
4. Resolve only review threads whose underlying concern is fully addressed. Never resolve a thread solely to make the count reach zero.
5. Re-read open threads, run a focused self-review of the fixes, and check CI with `gh pr checks`.

Wrap code identifiers such as class and type names in backticks in GitHub replies. Never force-push, approve the PR, request changes on behalf of a reviewer, bypass protections, or merge.

## Report

Return the PR URL, commits pushed, checks run, comments answered, threads resolved or left open, CI state, and a clear merge-ready or blocked conclusion.

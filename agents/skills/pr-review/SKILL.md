---
name: pr-review
description: Independently review a GitHub pull request in an isolated worktree and post new findings as concise inline comments in one COMMENT review. Use only when the user asks to leave or post review comments on a PR; do not use for a private read-only review.
---

# Review a Pull Request on GitHub

Review a PR independently, deduplicate against existing feedback, and post only new, defensible findings. Invoking this skill explicitly authorizes a `COMMENT` review, never approval or a request for changes.

## Resolve and isolate

1. Require a PR number or URL. Read the PR's repository, state, draft status, author, base, head branch, head repository, head SHA, additions, deletions, changed-file count, and commits.
2. Stop if the PR is closed or merged. Skip automated dependency-update authors unless the user explicitly asks to review them.
3. Create a clean isolated worktree using the host's worktree capability or `git worktree add`, then check out the PR with `gh pr checkout`. Never switch or modify the user's original checkout.
4. Record the checked-out SHA and verify it matches the PR head SHA.

## Build the deduplication baseline

Fetch all line-level review threads, issue comments, and submitted reviews. Treat the same underlying concern on the same or adjacent lines as already covered even when it is resolved or phrased differently.

## Review

Choose depth from the user's requested intensity or the PR's additions, deletions, file count, and risk. Inspect the complete diff plus enough surrounding implementation and tests to judge behavior. Run only focused, non-destructive checks that materially improve confidence.

Look for correctness bugs, regressions, security issues, data loss, concurrency problems, concrete performance failures, and meaningful missing tests. Exclude style preferences, unsupported speculation, pre-existing issues on untouched lines, and concerns already present in the baseline.

If a bounded read-only review agent is available, it may assist with analysis. It returns findings only and must not edit, commit, push, post a review, or clean up the worktree.

## Write and submit comments

For each surviving finding:

- Anchor it to a valid changed line on the current head SHA.
- Lead with the issue in one to three natural sentences; omit preambles, labels, confidence scores, emoji, and meta-commentary.
- Explain impact when it is not obvious. Use a GitHub suggestion block only for a small, unambiguous replacement.
- Wrap code identifiers such as class and type names in backticks.

Immediately before posting, re-read the PR head SHA. If it changed, do not post stale comments; refresh the checkout and validate findings again.

Submit all comments in one `gh api` review request with event `COMMENT` and the recorded head SHA. Construct JSON with a JSON-aware tool so comment text is escaped safely. Never use `APPROVE` or `REQUEST_CHANGES`. If no findings survive, post nothing.

If GitHub rejects an invalid line position, drop that comment instead of guessing another line. Remove the isolated worktree after the review, provided it has no unexpected changes.

## Report

Return the review URL, number of comments posted, duplicates dropped, intensity used, checks run, and draft status. If nothing was posted, say that no new findings survived review.

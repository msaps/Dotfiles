---
name: bug-hunter
description: Audit a GitHub codebase for recent regressions, latent correctness bugs, and concrete performance risks by delegating three read-only analyses in parallel, then create issues for confirmed findings. Use when the user explicitly asks for a bug hunt or autonomous audit.
---

# Bug Hunter

Run one bounded audit of the current repository. The analysis is read-only; the parent agent owns deduplication and GitHub issue creation.

## Preflight

Confirm that the working directory is a Git repository, `gh repo view` resolves a GitHub remote, and `gh auth status` succeeds. Stop with the actionable error if any check fails.

## Parallel analysis

Delegate these three tasks concurrently and wait for all of them:

1. `regression-bug-hunter`: inspect roughly the latest 10–15 commits for introduced defects and missing regression coverage.
2. `longstanding-bug-hunter`: inspect core code and error paths for older, reproducible correctness problems.
3. `performance-bug-hunter`: identify concrete performance or scaling failures appropriate to the project's actual workload.

Use the named custom agents when the host exposes them. Otherwise spawn general read-only subagents with the task text above plus the output contract below. Each delegated task is analysis-only: it must not edit files, commit, push, create issues, or perform any other external mutation.

Each finding must include `[BUG]` or `[PERFORMANCE]`, severity, file and line, evidence, impact, a concrete fix, and testable requirements. `NO_FINDINGS` means that task found nothing defensible.

## Validate and deduplicate

1. Discard speculative, style-only, and low-impact findings unless they affect authentication, payments, privacy, or data integrity.
2. Verify each surviving finding against the repository. Do not rely on a subagent's conclusion without checking its evidence.
3. Merge findings with the same root cause.
4. Read up to 200 open GitHub issues and skip substantially equivalent reports.

## Create issues

Use the `issue-creator` skill in automatic mode for each remaining finding:

- Map `[BUG]` to native issue type `bug`, using the finding's problem, fix, and requirements.
- Map `[PERFORMANCE]` to native issue type `task`, using the performance context as the overview and the proposed outcome as the goal.

Issue creation is authorized by an explicit bug-hunter request. If required fields are missing, skip that finding and report why instead of inventing details. Do not edit the repository.

## Report

Return counts for each analysis, issues created, duplicates skipped, rejected findings, and the URL of every new issue. If nothing survives validation, say `Bug hunter found no confirmed issues.`

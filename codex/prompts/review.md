---
description: Review the current branch against its base branch and report merge-blocking issues, regressions, and testing gaps.
---

# Review Current Branch

Review the current branch diff against its base branch and produce a findings-first code review.

## Preflight

1. Gather branch context.
   - Check `git branch --show-current`.
   - Resolve the base branch by preferring `main` when available; otherwise use the remote default branch.
   - Check `git status --short`.
   - Check `git diff --name-only <base>...HEAD`.
   - Check `git log --oneline <base>..HEAD`.
2. If the current branch is the base branch, stop and explain there is no review target.
3. If there are no commits or no diff versus the base branch, stop and explain there is nothing to review.

## Plan

1. Review the branch at the aggregate diff level.
2. Inspect file-level changes where risk is highest.
3. Focus on correctness, regressions, security, performance, and missing test coverage.
4. Return findings ordered by severity with file references.
5. If no issues are found, say so explicitly and note any residual risks or validation gaps.

## Commands

1. Read the branch summary.
   - Use `git diff --stat <base>...HEAD`.
   - Use `git diff --name-only <base>...HEAD`.
2. Read the full diff.
   - Use `git diff <base>...HEAD`.
3. Read relevant changed files directly when the diff alone is insufficient to judge behavior.
4. Run quick, non-destructive validation commands only when they materially improve confidence and are cheap enough for a review pass.
   - Example: targeted tests or lint for changed areas.
   - If validation is skipped, say so.
5. Do not edit files as part of this command unless the user explicitly asks for fixes after the review.

## Verification

1. Ensure every reported issue is grounded in the actual diff or changed-file context.
2. Prefer concrete behavioral risks over style commentary.
3. For each finding, explain:
   - What is wrong.
   - Why it matters.
   - Where it is in the code.
4. Avoid speculative findings that cannot be defended from the available evidence.

## Summary

The response must follow this review format:

```markdown
<Findings first, ordered by severity>

1. [severity] Brief issue title ([path/to/file.ext]:line)
Reason the change is risky or incorrect and the likely impact.

## Open Questions
- Optional clarifications or assumptions.

## Change Summary
- Very brief description of what the branch changes.
```

Additional response rules:

- Findings are the primary output.
- Use file references with line numbers when possible.
- Include missing tests as findings when the risk justifies it.
- If there are no findings, say `No findings.` and then list residual risks or unverified areas.

## Next Steps

1. Tell the user whether the branch looks ready to merge.
2. If findings exist, tell the user the highest-priority fix area first.

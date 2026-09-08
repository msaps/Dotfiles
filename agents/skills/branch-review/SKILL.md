---
name: branch-review
description: Review the current branch against its default base branch and report concrete correctness, security, performance, and test risks without editing files or posting externally.
---

# Review the Current Branch

Perform a findings-first, read-only review of the current branch.

## Workflow

1. Resolve the repository's default branch. Read the current branch, working-tree status, commits in `<base>..HEAD`, and aggregate diff in `<base>...HEAD`.
2. Stop if the current branch is the base or there is no branch diff.
3. Inspect the full diff and enough surrounding source and tests to understand behavior.
4. Run only focused, non-destructive checks that materially improve confidence. State what was not verified.
5. Report only defensible issues introduced by the branch. Prioritize correctness, regressions, security, data loss, performance, and meaningful test gaps over style preferences.

Do not edit files, create commits, push, or post GitHub comments unless the user separately asks for fixes or publication.

## Output

Order findings by severity and include a clickable file and line reference when possible:

```markdown
1. [high] Concise title (`path/to/file.ext:line`)
Explain the behavior, impact, and evidence.

## Open questions

- Include only questions that affect the review conclusion.

## Validation

- Commands run and residual gaps.
```

If there are no findings, say `No findings.` and list any residual validation gaps. End with whether the branch appears ready to merge.

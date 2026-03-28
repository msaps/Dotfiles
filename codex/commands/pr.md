---
description: Create a GitHub pull request for the current branch with a complete summary and auto-merge enabled when supported.
---

# Create Pull Request

Create a pull request for the current branch on GitHub using the repository's default base branch unless the current repo clearly uses `main`, in which case prefer `main`.

## Preflight

1. Gather repository state before making changes.
   - Check `git status --short`.
   - Check `git branch --show-current`.
   - Check `git remote -v`.
   - Check `git log --oneline main..HEAD` if `main` exists locally; otherwise detect the default branch from `origin/HEAD` and use that as the base.
   - Check `git diff --stat <base>...HEAD`.
2. Stop if there are uncommitted changes. Tell the user exactly which files are dirty and ask them to commit or stash first.
3. Stop if the current branch is `main`.
4. Verify `gh` is installed and authenticated before attempting PR creation.
5. Verify the branch has commits ahead of the base branch. If not, stop and explain that there is nothing to open a PR for.

## Plan

1. Determine the correct base branch.
2. Review the full branch scope, not just the latest commit.
3. Draft a concise imperative PR title under 72 characters.
4. Draft a PR body with `Summary`, `Changes`, and `Testing`.
5. Ensure the branch is pushed to `origin`, creating the upstream if needed.
6. Create the PR with `gh pr create`.
7. Attempt to enable squash auto-merge with `gh pr merge --auto --squash`.
8. Return the PR URL and final status.

## Commands

1. Detect the base branch.
   - Prefer `main` when it exists locally or on `origin`.
   - Otherwise use `git symbolic-ref refs/remotes/origin/HEAD` or equivalent to resolve the remote default branch.
2. Inspect the complete branch.
   - Review every commit in `<base>..HEAD`.
   - Review the aggregate diff in `<base>...HEAD`.
   - Use changed files and commit messages to understand the user-facing purpose, risks, and testing story.
3. Draft the PR title.
   - Imperative present tense.
   - Specific to the actual branch contents.
   - Avoid generic titles like `Update files`.
4. Draft the PR body in this format:

```markdown
## Summary

Brief description of what this PR does and why.

## Changes

- Key change
- Key change

## Testing

- Test run or manual verification
- If untested, say so explicitly
```

5. Push the branch if needed.
   - If there is no upstream, use `git push -u origin <branch>`.
   - Otherwise use `git push`.
6. Create the PR.
   - Use `gh pr create --base <base> --title "<title>" --body-file <tempfile>` or an equivalent non-interactive invocation.
7. Enable auto-merge if supported.
   - Run `gh pr merge --auto --squash`.
   - Never merge immediately.
   - If auto-merge is unavailable, report that clearly but still return the PR URL.

## Verification

1. Confirm `gh pr create` returned a PR URL.
2. Confirm the PR title and base branch match the analyzed branch.
3. Confirm auto-merge status.
   - Success: state that auto-merge is enabled.
   - Unsupported or blocked: state why.
4. If any command fails, stop and return the actionable error instead of guessing.

## Summary

Present the result in this structure:

```markdown
## Result
- **PR**: <url>
- **Base**: <base branch>
- **Title**: <title>
- **Auto-merge**: enabled | unavailable | failed
```

## Next Steps

1. Tell the user to review the PR on GitHub.
2. Call out any missing testing, unresolved warnings, or auto-merge limitations.

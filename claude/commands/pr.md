---
description: Create a pull request on GitHub for the current branch
---

Create a pull request for the current branch on GitHub.

## Instructions

1. **Gather context** by running these commands in parallel:
   - `git status` to check for uncommitted changes
   - `git branch --show-current` to get the current branch name
   - `git log --oneline main..HEAD` to see all commits being included
   - `git diff main...HEAD --stat` to see files changed

2. **Verify readiness**:
   - If there are uncommitted changes, warn the user and ask if they want to commit first
   - If on `main` branch, stop and tell the user to create a feature branch first
   - Ensure the branch is pushed to remote (push with `-u` if needed)

3. **Analyze the changes**:
   - Review ALL commits in the branch (not just the latest)
   - Understand the purpose and scope of the changes
   - Identify breaking changes, new features, bug fixes, etc.

4. **Create the PR title**:
   - Use imperative present tense (e.g., "Add feature", "Fix bug", "Update docs")
   - Keep under 72 characters
   - Be specific and descriptive

5. **Create the PR description** with this structure:
   ```markdown
   ## Summary

   Brief description of what this PR does and why.

   ## Changes

   - Bullet points of key changes
   - Include relevant technical details

   ## Testing

   How the changes were tested or should be tested.
   ```

6. **Create the pull request** using:
   ```bash
   gh pr create --title "Title" --body "$(cat <<'EOF'
   Description here
   EOF
   )"
   ```

7. **Enable auto-merge** if the repository supports it:
   ```bash
   gh pr merge --auto --squash
   ```
   - If auto-merge is not available, inform the user
   - **NEVER** merge the PR directly - only enable auto-merge

8. **Return the PR URL** so the user can review it

## Important Rules

- NEVER merge the PR directly - only enable auto-merge
- NEVER skip the description - always provide a detailed summary
- ALWAYS use imperative present tense for the title
- ALWAYS analyze all commits, not just the most recent one

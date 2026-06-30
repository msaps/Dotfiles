---
name: pr-finalize
description: Finalize a pull request by reading all comments, addressing required changes with commits and pushes, replying to comments inline, resolving threads, and performing a final review before merge. Use when a PR has received bot or human review feedback that needs to be acted on.
---

# Finalize PR

Fully work through all outstanding PR comments, address required changes, and confirm the PR is merge-ready.

## Usage

```
/pr-finalize [PR number]
```

If no PR number is provided, infer it from the current branch using `gh pr view`.

## Process

### Step 1: Load PR Context

```bash
gh pr view [number] --json number,title,body,headRefName,baseRefName,url,state
```

Confirm the PR is open. Check out the head branch if not already on it.

### Step 2: Fetch All Comments

Fetch both types of comment:

**Review thread comments** (line-level, resolvable) — use GraphQL to get thread IDs alongside comment content:

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          comments(first: 20) {
            nodes {
              id
              databaseId
              body
              path
              line
              author { login }
              createdAt
            }
          }
        }
      }
    }
  }
}' -f owner=OWNER -f repo=REPO -F number=NUMBER
```

**Issue-level comments** (top-level, not resolvable):

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments
```

### Step 3: Analyse Comments

For each thread/comment, categorise it:

- **Requires code change** — a bug, correctness issue, style violation, missing test, or explicit request to change something
- **Requires a reply only** — a question, clarification request, or discussion point where no code change is needed
- **Bot/CI comment** — read for signal (e.g. failing checks, lint errors) but do not reply to
- **Informational / already addressed** — note but skip

Think carefully before categorising. Do not dismiss substantive feedback as informational.

### Step 4: Address Code Changes

For each comment requiring a code change:

1. Read the relevant file(s) and fully understand the context.
2. Make the change. Prefer the simplest correct fix — do not over-engineer.
3. Commit immediately after each logical group of changes with a descriptive message referencing what feedback it addresses (without naming the commenter).
4. After all changes are committed, push:

```bash
git push
```

Only push once, after all commits are ready.

### Step 5: Reply to Comments

For each comment that was addressed or requires a reply:

**To reply to a review thread comment (line-level):**

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_database_id}/replies \
  -X POST \
  -f body="..."
```

**To reply to an issue-level comment**, post a new issue comment:

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments \
  -X POST \
  -f body="..."
```

Reply guidelines:
- For addressed changes: briefly confirm what was done (e.g. "Fixed — extracted the duplicated logic into a shared helper.")
- For reply-only: answer the question clearly and concisely.
- Do not reply to bot/CI comments.
- Do not be verbose. One or two sentences per reply is usually enough.

### Step 6: Resolve Review Threads

For each review thread that has been fully addressed, resolve it via GraphQL:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { isResolved }
  }
}' -f threadId=THREAD_NODE_ID
```

Only resolve threads where the underlying concern has been fully addressed by code or a satisfactory reply. Leave threads open if the discussion is ongoing or the feedback was deferred.

### Step 7: Sanity Check

Run a lightweight review focused only on changes made in this session:

```bash
gh pr diff [number]
gh pr checks [number]
```

Use `/code-review low` — this is a quick sanity check, not a full audit. The PR has already been through human review. Focus on:
- Regressions or bugs introduced by fixes made in this session
- Unresolved threads still showing as open
- Failing CI checks

Report a clear green light or list any remaining blockers. Do not approve the PR — that is for the human reviewer to do.

## Notes

- Never commit directly to `main`. If the PR head branch is somehow `main`, stop and warn.
- Never force-push.
- If a comment is ambiguous about whether action is required, err on the side of asking the user rather than guessing.
- Bot authors to recognise and not reply to: `github-actions[bot]`, `dependabot[bot]`, `codecov[bot]`, `renovate[bot]`, `coderabbitai[bot]`, `danger`, `sonarcloud[bot]`.
- **Never approve the PR** — approval is always the human reviewer's decision. If the PR requires approvals before merge, stop and inform the user; do not attempt to approve, bypass, or work around the requirement.

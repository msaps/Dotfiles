---
name: pr-review
description: Independently code review a GitHub pull request in an isolated worktree and post findings as short, human-sounding inline comments via a single review — never approves or requests changes. Use when asked to review a PR, do a second-opinion pass on someone's PR, or leave code-quality comments on a pull request.
---

# PR Review

Perform an independent code review of a pull request and leave concise, specific inline comments on it. This skill never approves a PR and never requests changes — its only output is comments, so a human still makes the merge decision.

## Usage

```
/pr-review <pr-number-or-url> [intensity]
```

`<pr-number-or-url>` is required — a bare PR number (uses the current repo) or a full PR URL (works from anywhere, e.g. to review a PR in a different repo).

`[intensity]` is optional: `low | medium | high | xhigh | max`. If omitted, pick one using **Step 4**.

## Scope Discipline (applies to every agent that can see this document)

If you are a sub-agent that was forked or spawned during this skill's execution — for review, dedup checking, or any other narrow task — and the rest of this document happens to be visible in your inherited context: your job is strictly limited to the task described in the prompt you were actually given. The steps below (posting reviews, cleaning up worktrees) are the parent session's remaining work, not yours, regardless of "proceed without pausing" language elsewhere in this file.

If your assigned task was to review, analyse, or check for duplicates: return your findings as text and stop there. Do not post comments, submit a review, or touch the worktree — even if you can see those steps nearby.

## Process

### Step 1: Resolve the PR

```bash
gh pr view <pr-number-or-url> --json number,title,url,state,isDraft,headRefName,headRepositoryOwner,headRepository,baseRefName,commits
```

From `.url`, extract `owner/repo`. Record the PR number, head branch name, and head commit SHA (`.commits[-1].oid`, or fetch separately after checkout in Step 3 to be safe).

Stop and report if:
- `state` is `CLOSED` or `MERGED` — there's nothing to review.
- The PR is authored by a bot (e.g. `dependabot[bot]`, `renovate[bot]`) — these don't benefit from a human-style review pass.

A `isDraft: true` PR is fine to review — note it in the final summary but proceed.

### Step 2: Isolate a Workspace

Never review inside the user's current working directory — it may have unrelated uncommitted work.

1. Enter a fresh worktree:

   ```
   EnterWorktree(name: "pr-review-<number>")
   ```

   If `EnterWorktree` is unavailable, fall back to:

   ```bash
   git fetch origin
   git worktree add ../pr-review-<number> origin/main
   cd ../pr-review-<number>
   ```

2. Check out the actual PR branch inside that isolated worktree:

   ```bash
   gh pr checkout <number>
   ```

   This works even for PRs from forks. After checkout, capture the exact head SHA you're reviewing:

   ```bash
   git rev-parse HEAD
   ```

### Step 3: Gather Existing Feedback (dedup baseline)

Before generating anything new, collect everything already said on this PR so the review never repeats a point someone else (or a previous run of this skill) already made.

**Review thread comments** (line-level):

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 20) {
            nodes { body path line author { login } }
          }
        }
      }
    }
  }
}' -f owner=OWNER -f repo=REPO -F number=NUMBER
```

**Issue-level comments:**

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments
```

**Existing reviews** (to see overall review state and any review-body-level feedback):

```bash
gh pr view <number> --json reviews
```

Build a mental list of "already covered" file/line + topic combinations, regardless of author (human, bot, or Claude in an earlier run) — resolved or not. A point that was already made and later resolved was still made; don't resurrect it.

### Step 4: Determine Review Intensity

If the user supplied an intensity, use it. Otherwise pick one based on the diff size (`gh pr diff <number> --stat`):

| Diff size | Intensity |
|---|---|
| Trivial (<50 lines, single file) | `low` |
| Small–medium multi-file change | `medium` |
| Large, cross-cutting, or new subsystem | `high` |
| Security-sensitive (auth, payments, migrations, secrets handling) | `max` |

Default to `medium` if the size is ambiguous.

### Step 5: Run the Code Review

While checked out on the PR branch in the isolated worktree, run:

```
/code-review <intensity>
```

Let it analyse the PR's diff and return its findings. Keep the full findings list — file, line, summary, and suggested fix for each.

### Step 6: Filter Out Duplicates

For each finding from Step 5, compare it against the "already covered" list from Step 3:

- Same file, same (or adjacent) line, and the same underlying concern → **drop it**, even if the earlier comment phrased it differently.
- A different concern on the same line → keep it.
- Anything genuinely new → keep it.

Also drop any finding that lands on a line that isn't part of the PR's diff (i.e. pre-existing code the PR didn't touch) — inline PR comments can only anchor to diff lines, and flagging untouched code isn't this PR's business anyway.

If nothing survives this filter, skip straight to Step 9 and report that no new issues were found — do not post an empty or "looks good" review; that's just noise on repeat runs.

### Step 7: Write the Comments

For each surviving finding, write one short inline comment. This is the part that most needs to not read like an AI wrote it:

- Lead with the issue, not a preamble. No "I noticed that...", "It looks like...", "Great work overall, but...".
- One to three sentences. State the problem and, if it's not obvious, why it matters.
- No confidence scores, no category labels, no restating the file/line (GitHub already shows that).
- No emoji, no meta-commentary about the review itself, no sign-off.
- Whenever a class or type name is referenced (e.g. `UserSession`, `ViewController`), wrap it in backticks so it renders as inline code.
- Where the fix is small and unambiguous, include it as a GitHub suggestion block so it's one-click-appliable:

  ```suggestion
  <replacement line(s)>
  ```

- Where the fix is more involved, describe it in a sentence rather than trying to force a suggestion block.

/ Bad: "I noticed that this function doesn't appear to handle the case where the input array is empty, which could potentially lead to unexpected behavior or a runtime error in production."
/ Good: "This throws on an empty array — worth guarding, or is that intentionally unreachable here?"

### Step 8: Submit as a Single Review

Post every surviving comment as one review submission, using the `COMMENT` event — **never** `APPROVE` or `REQUEST_CHANGES`, regardless of how severe or how clean the findings are. That decision belongs to a human.

```bash
gh api --method POST repos/{owner}/{repo}/pulls/{number}/reviews \
  --input - <<EOF
{
  "commit_id": "{head_sha}",
  "event": "COMMENT",
  "body": "",
  "comments": [
    {"path": "src/foo.ts", "line": 42, "side": "RIGHT", "body": "..."},
    {"path": "src/bar.ts", "start_line": 10, "line": 15, "side": "RIGHT", "body": "..."}
  ]
}
EOF
```

Leave the top-level review `body` empty (or a single short line at most, e.g. "A few small things.") when there are inline comments — the inline comments carry the review. Use `start_line`/`start_line` only for a genuinely multi-line concern; default to a single `line`.

### Step 9: Clean Up

```
ExitWorktree(action: "remove")
```

The review is read-only — there should never be uncommitted changes in the worktree, so this should always succeed cleanly.

### Step 10: Report Back

Tell the user, briefly:
- How many comments were posted, with a link to the review.
- How many findings were dropped as duplicates (if any).
- Intensity level used.
- If the PR was a draft, or authored by a bot and skipped, say so plainly.

## Notes

- **Never approve or request changes, under any circumstance.** If you find yourself reasoning "this is bad enough that it should block merge" — say that plainly in a comment instead of reaching for `REQUEST_CHANGES`.
- Never push commits, edit files, or otherwise modify the PR — this skill only reads code and posts comments.
- Never force-push, and never touch the user's original working directory — all work happens in the isolated worktree from Step 2.
- Bot authors to recognise and exclude from both the dedup baseline's "weight" and from being reviewed at all: `github-actions[bot]`, `dependabot[bot]`, `renovate[bot]`, `codecov[bot]`, `coderabbitai[bot]`, `danger`, `sonarcloud[bot]`.
- If `gh api` rejects a comment because the line isn't a valid diff position (can happen with outdated line numbers after a force-push mid-review), drop that comment rather than retrying with a guessed line.
- If the same PR is reviewed again later (e.g. after new commits), Step 3's dedup pass naturally covers comments this skill posted last time — there's no separate "have I reviewed this before" check needed.

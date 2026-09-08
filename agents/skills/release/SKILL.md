---
name: release
description: Prepare and push a semantic-version Git tag from the repository's default branch to trigger its release workflow. Use when the user explicitly asks to tag or release the current repository.
---

# Release by Tag

Create and push a semantic-version tag only after verifying the repository is ready.

## Preflight

1. Confirm the working tree is clean and the current branch is the repository's default branch.
2. Fetch remote and tag state, then confirm the local branch matches its upstream. Do not release from a stale or divergent branch.
3. Read the latest GitHub release or semantic-version tag, open pull requests, and all commits and changes since that version.
4. Check project files that declare a version. If they do not match the proposed release, stop and identify the files that need updating.

## Choose the Version

- Accept only semantic versions of the form `MAJOR.MINOR.PATCH`, optionally using the repository's existing `v` tag prefix.
- Use an explicit version supplied by the user when valid and greater than the latest release.
- Otherwise infer patch, minor, or major from the actual changes. Ask the user to approve an inferred version before creating the tag.
- If open pull requests could affect the release, report them and ask whether to continue.

## Publish

1. Show the exact tag and target commit before the irreversible push.
2. Create an annotated tag with a concise release summary.
3. Push only that tag to `origin`.
4. Return the tag's GitHub URL and note whether a release workflow was observed. Do not create a GitHub Release unless the user explicitly asks for one.

Never move or overwrite an existing tag, force-push, or tag an unverified commit.

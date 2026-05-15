---
description: Trigger a release on GitHub by pushing a tag
---

Trigger a release on GitHub by pushing a tag.

## Instructions

1. **Gather context** by running these commands in parallel:
   - Ensure user is currently on `main` branch.
   - Ensure that there are no current pull requests open for the repository.
   - The user must have provided a semantic version number along with the command. It must be formatted semantically like '1.2.3' with major, minor and patch components.

2. **Verify readiness**:
   - If not on `main` branch, prompt the user that they need to change to `main`.
   - If there are open pull requests, warn the user.
   - If the version number is semantically invalid reject the request.

3. **Create the Tag**:
   - Create a tag with the provided semantic version number.
   - Push it to the remote repo.

7. **Return the Tag on GitHub** so the user can review it

## Important Rules

- NEVER create a tag with an invalid version number.

---
description: Trigger a release on GitHub by pushing a tag
---

Trigger a release on GitHub by pushing a tag.

## Instructions

1. **Gather context** by running these commands in parallel:
   - Ensure user is currently on `main` branch.
   - Ensure that there are no current pull requests open for the repository.
   - Gather the latest tagged release from GitHub.
   - Gather the latest changes + commits on main since the last tag/release.

2. **Derive version number**
   - We must use semantic version numbers (e.g. `1.2.3`, `4.0.0`, `2.1.0`) ALWAYS.
   - If the user has provided an explicit version number in the command trigger, use that.
   - Otherwise look at the commits + changes you gathered since the last tag/release and decide an appropriate version number:
      - If the changes are purely fixes and can be considered a 'patch' release according to semver - bump the patch version.
      - If the changes are additive, include new features or can be considered a 'minor' release according to semver - bump the minor version.
      - If the changes are major or breaking and can be considered a 'major' release according to semver - bump the major version.
   - If you have derived the version number yourself, confirm it with the user before proceeding.

2. **Verify readiness**:
   - If not on `main` branch, prompt the user that they need to change to `main`.
   - If there are open pull requests, warn the user.
   - If the version number is semantically invalid, reject the request.
   - If the version number is not greater than the previous version, reject the request.

3. **Create the Tag**:
   - Create a tag with the provided semantic version number.
   - Push it to the remote repo.

7. **Return the Tag on GitHub** so the user can review it

## Important Rules

- NEVER create a tag with an invalid version number.

# .dotfiles

This is a personal macOS dotfiles repo: shell/tool config plus shared AI agent
configuration (skills, specialist agents, hooks, client rules) that gets
symlinked into `$HOME`. See [`docs/project-guide.md`](docs/project-guide.md)
for the full folder layout, symlink map, and bootstrap flow.

## Contributing
All changes must be agent-agnostic by design, ensure that they work with both Codex, Claude and other agents.

- Work on `main` directly - there is no need to do pull requests. Directly commit and push.
- Run the relevant configuration validators before committing.
- Keep client-specific behavior out of `agents/`. Anything that only applies
  to one client belongs under `claude/` or `codex/` instead.
- After touching anything under `agents/`, `claude/`, or `codex/`, run `make
  link` to confirm the symlinks it creates still resolve correctly.

## Two different "agent instructions" files
- `agents/AGENTS.md` is the **global** shared instruction file. `link.sh`
  symlinks it to `~/.agents/AGENTS.md`, `~/.claude/CLAUDE.md`, and
  `~/.codex/AGENTS.md`, so it applies to every project on the machine, not
  just this repo.
- This file is the **repo-local** instruction file for working inside
  `.dotfiles` itself. Root `CLAUDE.md` is a symlink to this file so Claude
  Code picks up the same guidance as Codex when it opens this repo directly.
  Don't confuse edits meant for one with the other.

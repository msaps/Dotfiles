# Project Guide

## Purpose

This repository is a home-directory bootstrap for a macOS development machine.

It does not use a dotfile manager. Instead, it keeps a small set of config files in normal folders and provides separate install and link entrypoints to:

1. install prerequisite tooling
2. install packages and applications
3. symlink managed files into `$HOME`
4. install local fonts

The result is a repo that is easy to inspect and easy to rerun on an existing machine.

## Layout

The top-level directories are organized by target tool rather than by automation step.

| Path | Purpose |
| --- | --- |
| [`Makefile`](/Users/msaps/.dotfiles/Makefile) | Public `install` and `link` entrypoints |
| [`install.sh`](/Users/msaps/.dotfiles/install.sh) | Full machine bootstrap |
| [`link.sh`](/Users/msaps/.dotfiles/link.sh) | Symlink-only configuration refresh |
| [`Brewfile`](/Users/msaps/.dotfiles/Brewfile) | Homebrew formulae and casks |
| [`Gemfile`](/Users/msaps/.dotfiles/Gemfile) | Ruby gem dependency manifest |
| [`zsh/`](/Users/msaps/.dotfiles/zsh) | Shell startup files |
| [`git/`](/Users/msaps/.dotfiles/git) | Global Git config and ignore rules |
| [`homebrew/`](/Users/msaps/.dotfiles/homebrew) | Homebrew environment file |
| [`gh/`](/Users/msaps/.dotfiles/gh) | GitHub CLI config |
| [`claude/`](/Users/msaps/.dotfiles/claude) | Claude Code settings and hooks |
| [`codex/`](/Users/msaps/.dotfiles/codex) | Codex execution rules and custom-agent adapters |
| [`agents/`](/Users/msaps/.dotfiles/agents) | Shared instructions, skills, and specialist-agent prompts |
| [`misc/`](/Users/msaps/.dotfiles/misc) | Small standalone dotfiles such as `.curlrc` |
| [`iterm/`](/Users/msaps/.dotfiles/iterm) | Fonts plus exported iTerm profile |

## Bootstrap Flow

Run `make install` for a full bootstrap. It invokes [`install.sh`](/Users/msaps/.dotfiles/install.sh), which currently does the following in order:

1. Ensures the repo exists at `~/.dotfiles`, cloning it if needed.
2. Installs Xcode Command Line Tools if `xcode-select` is missing.
3. Installs Homebrew if `brew` is unavailable.
4. Runs `brew bundle` against [`Brewfile`](/Users/msaps/.dotfiles/Brewfile).
5. Installs Oh My Zsh and the `zsh-autosuggestions` plugin if missing.
6. Invokes [`link.sh`](/Users/msaps/.dotfiles/link.sh) to create or refresh all managed symlinks.
7. Copies bundled iTerm fonts into `~/Library/Fonts`.

Run `make link` after pulling ordinary configuration changes. It invokes `link.sh` directly, without package installation or macOS setup. Use `make install` when bootstrap dependencies or the `Brewfile` changed.

## Symlink Map

The repo uses explicit symlinks rather than a generated map. This is the current behavior of [`link.sh`](/Users/msaps/.dotfiles/link.sh):

| Repo file | Linked location |
| --- | --- |
| [`zsh/.zshrc`](/Users/msaps/.dotfiles/zsh/.zshrc) | `~/.zshrc` |
| [`zsh/.zshenv`](/Users/msaps/.dotfiles/zsh/.zshenv) | `~/.zshenv` |
| [`zsh/.profile`](/Users/msaps/.dotfiles/zsh/.profile) | `~/.profile` |
| [`git/.gitconfig`](/Users/msaps/.dotfiles/git/.gitconfig) | `~/.gitconfig` |
| [`git/.gitignore`](/Users/msaps/.dotfiles/git/.gitignore) | `~/.gitignore` |
| [`misc/.curlrc`](/Users/msaps/.dotfiles/misc/.curlrc) | `~/.curlrc` |
| [`agents/AGENTS.md`](/Users/msaps/.dotfiles/agents/AGENTS.md) | `~/.agents/AGENTS.md` |
| [`agents/hooks`](/Users/msaps/.dotfiles/agents/hooks) | `~/.agents/hooks` |
| [`agents/AGENTS.md`](/Users/msaps/.dotfiles/agents/AGENTS.md) | `~/.claude/CLAUDE.md` |
| [`claude/settings.json`](/Users/msaps/.dotfiles/claude/settings.json) | `~/.claude/settings.json` |
| [`agents/AGENTS.md`](/Users/msaps/.dotfiles/agents/AGENTS.md) | `~/.codex/AGENTS.md` |
| Each directory in [`agents/skills`](/Users/msaps/.dotfiles/agents/skills) | `~/.agents/skills/<name>` and `~/.claude/skills/<name>` |
| Each file in [`agents/agents`](/Users/msaps/.dotfiles/agents/agents) | `~/.agents/agents/<name>.md` and `~/.claude/agents/<name>.md` |
| Each file in [`codex/agents`](/Users/msaps/.dotfiles/codex/agents) | `~/.codex/agents/<name>.toml` |
| [`codex/hooks.json`](/Users/msaps/.dotfiles/codex/hooks.json) | `~/.codex/hooks.json` |
| [`codex/rules`](/Users/msaps/.dotfiles/codex/rules) | `~/.codex/rules` |
| [`gh/config.yml`](/Users/msaps/.dotfiles/gh/config.yml) | `~/.config/gh/config.yml` |

## What Each Area Configures

### Shell

[`zsh/.zshrc`](/Users/msaps/.dotfiles/zsh/.zshrc) sets up:

- Oh My Zsh with the `agnoster` theme
- plugins for `git`, `z`, `xcode`, `macos`, and `zsh-autosuggestions`
- Homebrew shell environment
- `rbenv`
- Volta paths
- a few local aliases for `code`, Tower, and Xcode DerivedData cleanup

[`zsh/.zshenv`](/Users/msaps/.dotfiles/zsh/.zshenv) and [`zsh/.profile`](/Users/msaps/.dotfiles/zsh/.profile) currently just make Volta available in login and non-login shells.

### Development Tooling

[`Brewfile`](/Users/msaps/.dotfiles/Brewfile) is the machine bootstrap inventory. Right now it installs:

- CLI tools like `git`, `gh`, `curl`, `aria2`, and `cloc`
- development tools like `go`, `rbenv`, `volta`, `swiftlint`, `vapor`, and `xcodes`
- desktop apps including iTerm2, VS Code, Tower, Proxyman, Claude, and a few utility apps

[`Gemfile`](/Users/msaps/.dotfiles/Gemfile) is intentionally small. Ruby version selection and `bundle install` remain manual steps; the bootstrap installs `rbenv` but does not configure a Ruby version.

### Git and GitHub

[`git/.gitconfig`](/Users/msaps/.dotfiles/git/.gitconfig) keeps the global user identity, default branch, and a shared global ignore file.

[`gh/config.yml`](/Users/msaps/.dotfiles/gh/config.yml) stores GitHub CLI behavior such as aliases and prompt preferences.

### AI Tooling

[`agents/AGENTS.md`](/Users/msaps/.dotfiles/agents/AGENTS.md) is shared between Claude Code and Codex so both tools inherit the same local working rules. Reusable workflows use the open `SKILL.md` format and are linked into both clients' user skill directories.

[`claude/settings.json`](/Users/msaps/.dotfiles/claude/settings.json) manages Claude permissions and enabled plugins. Claude and Codex both run the shared Git push hook in [`agents/hooks`](/Users/msaps/.dotfiles/agents/hooks), which blocks bare force pushes and permits `--force-with-lease` only from `feature/*` branches.

Codex user configuration remains isolated in `~/.codex/config.toml` and is not managed by this repository. This allows Codex to persist preferences, project trust, hook approvals, and UI state independently on each machine.

[`codex/rules/default.rules`](/Users/msaps/.dotfiles/codex/rules/default.rules) manages durable Codex command approvals and denials, aligned with the intent of Claude's permission lists where the clients expose equivalent controls.

## Assumptions and Constraints

This repo currently assumes:

- macOS
- a user account with a writable home directory
- internet access during bootstrap
- Homebrew installed to `/opt/homebrew`
- the repo living at `~/.dotfiles`

Those assumptions are fine for a personal machine bootstrap, but they are worth remembering before trying to generalize the setup.

## How To Extend It

When adding a new managed config:

1. Store the source file in a tool-specific folder in the repo.
2. Add the corresponding symlink step to [`link.sh`](/Users/msaps/.dotfiles/link.sh).
3. If the tool needs installation, add it to [`Brewfile`](/Users/msaps/.dotfiles/Brewfile) or document the manual step.
4. Update this guide if the bootstrap flow or symlink map changes.

Keeping those three pieces in sync is the main maintenance rule for this project.

# Project Guide

## Purpose

This repository is a home-directory bootstrap for a macOS development machine.

It does not use a dotfile manager. Instead, it keeps a small set of config files in normal folders and uses a single install script to:

1. install prerequisite tooling
2. install packages and applications
3. symlink managed files into `$HOME`
4. finish language-specific setup such as Ruby gems and local fonts

The result is a repo that is easy to inspect and easy to rerun on an existing machine.

## Layout

The top-level directories are organized by target tool rather than by automation step.

| Path | Purpose |
| --- | --- |
| [`install.sh`](/Users/msaps/.dotfiles/install.sh) | Main bootstrap entrypoint |
| [`Brewfile`](/Users/msaps/.dotfiles/Brewfile) | Homebrew formulae and casks |
| [`Gemfile`](/Users/msaps/.dotfiles/Gemfile) | Ruby gems installed after `rbenv` is configured |
| [`zsh/`](/Users/msaps/.dotfiles/zsh) | Shell startup files |
| [`git/`](/Users/msaps/.dotfiles/git) | Global Git config and ignore rules |
| [`homebrew/`](/Users/msaps/.dotfiles/homebrew) | Homebrew environment file |
| [`gh/`](/Users/msaps/.dotfiles/gh) | GitHub CLI config |
| [`claude/`](/Users/msaps/.dotfiles/claude) | Claude configuration and custom commands |
| [`codex/`](/Users/msaps/.dotfiles/codex) | Codex configuration and custom commands |
| [`agents/`](/Users/msaps/.dotfiles/agents) | Shared agent instructions symlinked into local AI tool directories |
| [`misc/`](/Users/msaps/.dotfiles/misc) | Small standalone dotfiles such as `.curlrc` |
| [`iterm/`](/Users/msaps/.dotfiles/iterm) | Fonts plus exported iTerm profile |

## Bootstrap Flow

[`install.sh`](/Users/msaps/.dotfiles/install.sh) is the only automation entrypoint. It currently does the following in order:

1. Ensures the repo exists at `~/.dotfiles`, cloning it if needed.
2. Installs Xcode Command Line Tools if `xcode-select` is missing.
3. Installs Homebrew if `brew` is unavailable.
4. Symlinks [`homebrew/brew.env`](/Users/msaps/.dotfiles/homebrew/brew.env) into `~/.homebrew/brew.env`.
5. Runs `brew bundle` against [`Brewfile`](/Users/msaps/.dotfiles/Brewfile).
6. Installs Oh My Zsh and the `zsh-autosuggestions` plugin if missing.
7. Creates or refreshes symlinks for all managed dotfiles.
8. Installs Ruby `3.2.2` with `rbenv`, sets it global, then runs `bundle install`.
9. Copies bundled iTerm fonts into `~/Library/Fonts`.

Because the symlink step uses `ln -sf`, rerunning the installer is the intended update path.

## Symlink Map

The repo uses explicit symlinks rather than a generated map. This is the current behavior of [`install.sh`](/Users/msaps/.dotfiles/install.sh):

| Repo file | Linked location |
| --- | --- |
| [`zsh/.zshrc`](/Users/msaps/.dotfiles/zsh/.zshrc) | `~/.zshrc` |
| [`zsh/.zshenv`](/Users/msaps/.dotfiles/zsh/.zshenv) | `~/.zshenv` |
| [`zsh/.profile`](/Users/msaps/.dotfiles/zsh/.profile) | `~/.profile` |
| [`git/.gitconfig`](/Users/msaps/.dotfiles/git/.gitconfig) | `~/.gitconfig` |
| [`git/.gitignore`](/Users/msaps/.dotfiles/git/.gitignore) | `~/.gitignore` |
| [`misc/.curlrc`](/Users/msaps/.dotfiles/misc/.curlrc) | `~/.curlrc` |
| [`agents/AGENTS.md`](/Users/msaps/.dotfiles/agents/AGENTS.md) | `~/.agents/AGENTS.md` |
| [`agents/AGENTS.md`](/Users/msaps/.dotfiles/agents/AGENTS.md) | `~/.claude/CLAUDE.md` |
| [`claude/commands`](/Users/msaps/.dotfiles/claude/commands) | `~/.claude/commands` |
| [`claude/settings.json`](/Users/msaps/.dotfiles/claude/settings.json) | `~/.claude/settings.json` |
| [`agents/AGENTS.md`](/Users/msaps/.dotfiles/agents/AGENTS.md) | `~/.codex/AGENTS.md` |
| [`codex/commands`](/Users/msaps/.dotfiles/codex/commands) | `~/.codex/commands` |
| [`codex/config.toml`](/Users/msaps/.dotfiles/codex/config.toml) | `~/.codex/config.toml` |
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

[`Gemfile`](/Users/msaps/.dotfiles/Gemfile) is intentionally small and piggybacks on the Ruby version the installer configures.

### Git and GitHub

[`git/.gitconfig`](/Users/msaps/.dotfiles/git/.gitconfig) keeps the global user identity, default branch, and a shared global ignore file.

[`gh/config.yml`](/Users/msaps/.dotfiles/gh/config.yml) stores GitHub CLI behavior such as aliases and prompt preferences.

### AI Tooling

[`agents/AGENTS.md`](/Users/msaps/.dotfiles/agents/AGENTS.md) is shared between Claude and Codex so both tools inherit the same local working rules.

[`claude/settings.json`](/Users/msaps/.dotfiles/claude/settings.json) manages Claude permissions and enabled plugins.

[`codex/config.toml`](/Users/msaps/.dotfiles/codex/config.toml) manages Codex MCP server setup and project trust.

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
2. Add the corresponding symlink step to [`install.sh`](/Users/msaps/.dotfiles/install.sh).
3. If the tool needs installation, add it to [`Brewfile`](/Users/msaps/.dotfiles/Brewfile) or document the manual step.
4. Update this guide if the bootstrap flow or symlink map changes.

Keeping those three pieces in sync is the main maintenance rule for this project.

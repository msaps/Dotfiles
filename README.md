# Dotfiles

Personal macOS dotfiles used for two jobs:

1. Keep everyday shell and tool configuration under version control.
2. Bootstrap a fresh machine by installing packages and wiring the managed files into `$HOME`.

The repository is intentionally simple. Most folders mirror a target location in the home directory. `make install` bootstraps a machine, while `make link` only refreshes the user-level symlinks.

## Quick Start

Clone the repo into `~/.dotfiles` and run the installer:

```bash
git clone https://github.com/msaps/Dotfiles.git ~/.dotfiles
make -C ~/.dotfiles install
```

If the repo is already present:

```bash
cd ~/.dotfiles
make install
```

To refresh configuration without installing packages or changing macOS settings:

```bash
make link
```

## What This Repo Manages

- Shell startup files for `zsh`
- Global Git config and ignore rules
- Homebrew environment and package list
- GitHub CLI config
- Shared Claude Code and Codex skills, instructions, and specialist agents
- iTerm fonts and profile export
- A few machine-level helper files such as `.curlrc`

## Project Guide

The main project documentation lives in [`docs/project-guide.md`](~/.dotfiles/docs/project-guide.md). It covers:

- the folder layout
- the symlink map
- the installer flow
- bootstrap assumptions
- how to update the repo safely

## Manual Steps After Install

Some tools still require interactive setup after the script finishes:

1. Restart the shell or run `exec zsh`.
2. Import [`iterm/iterm-profiles.json`](~/.dotfiles/iterm/iterm-profiles.json) into iTerm2 if you want the saved profile.
3. Run `gh auth login`.
4. Launch Claude Code and Codex and complete any first-run authentication.

Portable Codex defaults live in `codex/config.toml`, which `make install` links
to `/etc/codex/config.toml` using the native system configuration layer. The
higher-precedence `~/.codex/config.toml` remains local and writable so Codex can
store project trust, hook approvals, and UI state without changing tracked
files. Installing the system link requires a one-time macOS administrator
prompt; rerun `make link-codex-system-config` if the link ever needs repairing.
Durable command policy lives in `codex/rules/`, custom agent definitions in
`codex/agents/`, and shared workflows in `agents/skills/`.

## Updating

Pull the latest changes and refresh the symlinks:

```bash
cd ~/.dotfiles
git pull --rebase
make link
```

Use `make install` instead when bootstrap dependencies or the `Brewfile` changed.

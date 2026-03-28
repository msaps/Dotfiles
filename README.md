# Dotfiles

Personal macOS dotfiles used for two jobs:

1. Keep everyday shell and tool configuration under version control.
2. Bootstrap a fresh machine by installing packages and wiring the managed files into `$HOME`.

The repository is intentionally simple. Most folders mirror a target location in the home directory, and [`install.sh`](/Users/msaps/.dotfiles/install.sh) is the bootstrap script that installs dependencies and recreates the symlinks.

## Quick Start

Clone the repo into `~/.dotfiles` and run the installer:

```bash
git clone git@github.com:msaps/Dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

If the repo is already present:

```bash
cd ~/.dotfiles
./install.sh
```

## What This Repo Manages

- Shell startup files for `zsh`
- Global Git config and ignore rules
- Homebrew environment and package list
- GitHub CLI config
- Claude and Codex local agent configuration
- iTerm fonts and profile export
- A few machine-level helper files such as `.curlrc`

## Project Guide

The main project documentation lives in [`docs/project-guide.md`](/Users/msaps/.dotfiles/docs/project-guide.md). It covers:

- the folder layout
- the symlink map
- the installer flow
- bootstrap assumptions
- how to update the repo safely

## Manual Steps After Install

Some tools still require interactive setup after the script finishes:

1. Restart the shell or run `exec zsh`.
2. Import [`iterm/iterm-profiles.json`](/Users/msaps/.dotfiles/iterm/iterm-profiles.json) into iTerm2 if you want the saved profile.
3. Run `gh auth login`.
4. Launch Claude and Codex and complete any first-run authentication.

## Updating

Pull the latest changes and rerun the installer:

```bash
cd ~/.dotfiles
git pull
./install.sh
```

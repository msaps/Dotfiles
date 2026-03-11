# Dotfiles

Personal dotfiles for macOS development environment setup.

## Quick Install

On a fresh Mac, run:

```bash
git clone git@github.com:msaps/Dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
```

Or if the repo is already cloned:

```bash
~/.dotfiles/install.sh
```

## What's Included

### Shell
- **ZSH** with Oh My ZSH
- **zsh-autosuggestions** plugin
- Custom aliases and PATH configuration

### Development Tools
- **Homebrew** packages and casks
- **rbenv** + Ruby 3.2.2
- **Volta** for Node.js
- **SwiftLint**, **Vapor**, **xcodes**

### Applications
- VS Code, Cursor, iTerm2, Tower
- Claude, Figma, Proxyman
- And more (see `Brewfile`)

### Configurations
- Git config with global gitignore
- GitHub CLI settings
- Claude Code preferences
- iTerm2 fonts (Roboto Mono for Powerline)

## Structure

```
~/.dotfiles/
├── install.sh       # Main install script
├── Brewfile         # Homebrew packages
├── Gemfile          # Ruby gems
├── zsh/             # ZSH configuration
├── git/             # Git configuration
├── claude/          # Claude Code settings
├── gh/              # GitHub CLI config
├── misc/            # Other dotfiles
└── iterm/           # iTerm2 fonts & profiles
```

## Manual Steps

After running the install script:

1. **Restart terminal** or run `exec zsh`
2. **Import iTerm2 profile**: Preferences > Profiles > Import JSON
3. **Authenticate GitHub CLI**: `gh auth login`
4. **Authenticate Claude Code**: `claude` and follow prompts

## Updating

Pull the latest changes and re-run the install script:

```bash
cd ~/.dotfiles && git pull && ./install.sh
```

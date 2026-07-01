#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dotfiles..."

# macOS defaults
echo "==> Configuring macOS defaults..."
if ! defaults read com.apple.finder AppleShowAllFiles 2>/dev/null | grep -q "1"; then
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder 2>/dev/null || true
fi

# Clone or update dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "==> Cloning dotfiles repository..."
    git clone git@github.com:msaps/Dotfiles.git "$DOTFILES_DIR"
else
    echo "==> Updating dotfiles..."
    git -C "$DOTFILES_DIR" pull --rebase
fi

cd "$DOTFILES_DIR"

# Install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "==> Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press enter when the installation is complete."
    read -r
fi

# Install Homebrew
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
mkdir -p "$HOME/.homebrew"
ln -sf "$DOTFILES_DIR/homebrew/brew.env" "$HOME/.homebrew/brew.env"

# Install packages from Brewfile (skip if no write access)
BREW_PREFIX="$(brew --prefix)"
if [ ! -w "$BREW_PREFIX/Cellar" ]; then
    echo "==> Skipping Homebrew packages (no write access to $BREW_PREFIX/Cellar)"
elif brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
    echo "==> Homebrew packages already up to date"
else
    echo "==> Trusting Homebrew taps..."
    brew tap productdevbook/tap
    brew tap steipete/tap
    brew trust productdevbook/tap
    brew trust steipete/tap
    echo "==> Installing Homebrew packages..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# Install Oh My ZSH
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> Installing Oh My ZSH..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install ZSH plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "==> Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Create symlinks
echo "==> Creating symlinks..."

# ZSH
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES_DIR/zsh/.profile" "$HOME/.profile"

# Git
ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/git/.gitignore" "$HOME/.gitignore"

# Misc
ln -sf "$DOTFILES_DIR/misc/.curlrc" "$HOME/.curlrc"
ln -sf "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

# AI agents (Claude Code, Codex, etc.)
echo "==> Setting up AI agents..."
mkdir -p "$HOME/.agents"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
mkdir -p "$HOME/.agents/skills"
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
ln -sfn "$DOTFILES_DIR/claude/commands" "$HOME/.claude/commands"
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude/skills"
mkdir -p "$HOME/.codex"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$DOTFILES_DIR/codex/prompts" "$HOME/.codex/prompts"
ln -sfn "$DOTFILES_DIR/codex/rules" "$HOME/.codex/rules"
# Symlink each skill individually so external tools can add skills alongside
for skill_dir in "$DOTFILES_DIR/agents/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" "$HOME/.agents/skills/$skill_name"
    ln -sfn "$skill_dir" "$HOME/.claude/skills/$skill_name"
done
# Symlink each agent individually so external tools can add agents alongside
mkdir -p "$HOME/.agents/agents"
mkdir -p "$HOME/.claude/agents"
for agent_file in "$DOTFILES_DIR/agents/agents"/*.md; do
    [ -f "$agent_file" ] || continue
    agent_name=$(basename "$agent_file")
    ln -sf "$agent_file" "$HOME/.agents/agents/$agent_name"
    ln -sf "$agent_file" "$HOME/.claude/agents/$agent_name"
done

# GitHub CLI
mkdir -p "$HOME/.config/gh"
ln -sf "$DOTFILES_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"

# Install Ruby
echo "==> Setting up Ruby..."
RUBY_VERSION=$(rbenv install --list | grep -E '^\s*3\.4\.[0-9]+$' | tail -1 | tr -d ' ')
if ! rbenv versions | grep -q "$RUBY_VERSION"; then
    rbenv install "$RUBY_VERSION"
fi
rbenv global "$RUBY_VERSION"
eval "$(rbenv init - zsh)"

# Install Ruby gems
echo "==> Installing Ruby gems..."
gem install bundler --conservative
bundle install

# Install iTerm2 fonts
echo "==> Installing iTerm2 fonts..."
cp "$DOTFILES_DIR/iterm/"*.ttf "$HOME/Library/Fonts/" 2>/dev/null || true

echo ""
echo "==> Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Import iTerm2 profile from: $DOTFILES_DIR/iterm/iterm-profiles.json"
echo "  3. Authenticate GitHub CLI: gh auth login"
echo ""

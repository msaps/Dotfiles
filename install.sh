#!/bin/bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"

echo "==> Installing dotfiles..."

# Clone dotfiles if not already present
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "==> Cloning dotfiles repository..."
    git clone git@github.com:msaps/Dotfiles.git "$DOTFILES_DIR"
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
if ! command -v brew &>/dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install packages from Brewfile
echo "==> Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

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

# Claude Code
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# GitHub CLI
mkdir -p "$HOME/.config/gh"
ln -sf "$DOTFILES_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"

# Install Ruby
echo "==> Setting up Ruby..."
if ! rbenv versions | grep -q "3.2.2"; then
    rbenv install 3.2.2
fi
rbenv global 3.2.2
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

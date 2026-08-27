#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove a broken symlink so mkdir -p can create a real directory in its place
ensure_dir() {
    local dir="$1"
    [ -L "$dir" ] && [ ! -e "$dir" ] && rm "$dir"
    mkdir -p "$dir"
}

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

# Homebrew
mkdir -p "$HOME/.homebrew"
ln -sf "$DOTFILES_DIR/homebrew/brew.env" "$HOME/.homebrew/brew.env"

# GitHub CLI
mkdir -p "$HOME/.config/gh"
ln -sf "$DOTFILES_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"

# AI agents (Claude Code, Codex, etc.)
echo "==> Setting up AI agents..."
ensure_dir "$HOME/.agents"
ensure_dir "$HOME/.agents/skills"
ensure_dir "$HOME/.agents/agents"
ensure_dir "$HOME/.claude"
ensure_dir "$HOME/.claude/skills"
ensure_dir "$HOME/.claude/agents"
ensure_dir "$HOME/.codex"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$DOTFILES_DIR/claude/commands" "$HOME/.claude/commands"
ln -sfn "$DOTFILES_DIR/claude/hooks" "$HOME/.claude/hooks"
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$DOTFILES_DIR/codex/prompts" "$HOME/.codex/prompts"
ln -sfn "$DOTFILES_DIR/codex/rules" "$HOME/.codex/rules"
# Symlink each skill individually so external tools can add skills alongside
for skill_dir in "$DOTFILES_DIR/agents/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" "$HOME/.agents/skills/$skill_name"
    ln -sfn "$skill_dir" "$HOME/.claude/skills/$skill_name"
done
# Symlink each agent individually so external tools can add agents alongside
for agent_file in "$DOTFILES_DIR/agents/agents"/*.md; do
    [ -f "$agent_file" ] || continue
    agent_name=$(basename "$agent_file")
    ln -sf "$agent_file" "$HOME/.agents/agents/$agent_name"
    ln -sf "$agent_file" "$HOME/.claude/agents/$agent_name"
done

echo "==> Linking complete!"

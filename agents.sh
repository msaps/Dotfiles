#!/bin/bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"

echo "==> Setting up AI agents..."

# Agents
mkdir -p "$HOME/.agents"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"

# Claude Code
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$DOTFILES_DIR/claude/commands" "$HOME/.claude/commands"
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# Codex
mkdir -p "$HOME/.codex"
ln -sf "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sf "$DOTFILES_DIR/codex/prompts" "$HOME/.codex/prompts"
ln -sf "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml"
ln -sf "$DOTFILES_DIR/codex/rules" "$HOME/.codex/rules"

echo "==> AI agents setup complete!"

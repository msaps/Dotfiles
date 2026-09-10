DOTFILES_DIR := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" && pwd)

.PHONY: install link link-codex-system-config

install:
	@bash "$(DOTFILES_DIR)/install.sh"

link:
	@bash "$(DOTFILES_DIR)/link.sh"

link-codex-system-config:
	@if [ "$$(readlink /etc/codex/config.toml 2>/dev/null)" != "$(DOTFILES_DIR)/codex/config.toml" ]; then \
		sudo mkdir -p /etc/codex; \
		sudo ln -sfn "$(DOTFILES_DIR)/codex/config.toml" /etc/codex/config.toml; \
	fi

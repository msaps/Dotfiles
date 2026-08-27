DOTFILES_DIR := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" && pwd)

.PHONY: install link

install:
	@bash "$(DOTFILES_DIR)/install.sh"

link:
	@bash "$(DOTFILES_DIR)/link.sh"

#! bin/bash

# Install Homebrew
which -s brew
if [[ $? != 0 ]] ; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Utilities
function install() {
	brew install $1;
}

# General
install git;

# Core Casks
install iterm2;
install tower;
install visual-studio-code;

# Ruby
install rbenv;

# Node
install volta;

# iOS
install swiftlint;
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

# Pre-requisites
install cask;

# General
install git;
install rbenv;

# iOS
install swiftlint;

# Casks
install tower;
install iterm2;
install visual-studio-code;
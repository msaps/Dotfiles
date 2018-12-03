#! bin/bash

# Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Utilities
function install_brew() {
	brew install $1;
}
function install_cask() {
	brew cask install $1;
}

# Pre-requisites
install_brew cask;

# General
install_brew git;
install_brew rbenv;
install_brew python;
install_brew rbenv;

# iOS
install_brew carthage;
install_brew swiftlint;

# Casks
install_cask spotify;
install_cask google-chrome;
install_cask slack;
install_cask tower;
install_cask iterm2;
install_cask visual-studio-code;
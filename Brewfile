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

# General
install_brew zsh;
install_brew git;
install_brew ruby;
install_brew python;

# iOS
install_brew carthage;
install_brew swiftlint;

# Casks
install_cask spotify;
install_cask google-chrome;
install_cask slack;
install_cask tower;
install_cask iterm2;
# ZSH Config
export ZSH=~/.oh-my-zsh # Path to your oh-my-zsh installation.
ZSH_THEME="agnoster" # Theme

# Plugins
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
plugins=(git z xcode macos zsh-autosuggestions)

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

# Aliases
alias zshconfig="code ~/.zshrc"
alias code="code ./"
alias l="ls"
alias tower="gittower ./"
alias tw="gittower ./"
alias ddata="rm -r ~/Library/Developer/Xcode/DerivedData"
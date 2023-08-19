# ZSH Config
export ZSH=~/.oh-my-zsh # Path to your oh-my-zsh installation.
ZSH_THEME="agnoster" # Theme
source $ZSH/oh-my-zsh.sh
source $HOME/.zshenv

# Plugins
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
plugins=(git zsh-autosuggestions z xcode macos)

# User configuration
export LANG=en_US.UTF-8

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Aliases
alias zshconfig="code ~/.zshrc"
alias code="code ./"
alias l="ls"
alias tower="gittower ./"
alias tw="gittower ./"
alias ddata="rm -r ~/Library/Developer/Xcode/DerivedData"

# Init rbenv
eval "$(rbenv init - zsh)"
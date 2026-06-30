# ZSH Config
export ZSH=~/.oh-my-zsh # Path to your oh-my-zsh installation.
ZSH_THEME="agnoster" # Theme

# Plugins
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
plugins=(git z xcode macos zsh-autosuggestions)

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$PATH"

# Rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# Volta
export VOLTA_HOME="$HOME/.volta"

# User configuration
export LANG=en_US.UTF-8

# FZF
eval "$(fzf --zsh)"

# Aliases
alias zshconfig="code ~/.zshrc"
alias lg="lazygit"
alias t="tmux"
alias ta="tmux attach"
alias tl="tmux ls"
alias tn="tmux new -s"
alias code="code ./"
alias l="ls"
alias tower="gittower ./"
alias tw="gittower ./"
alias ddata="rm -r ~/Library/Developer/Xcode/DerivedData"

source $ZSH/oh-my-zsh.sh

# Machine-local overrides (not tracked)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Docker Desktop
fpath=(~/.docker/completions $fpath)
autoload -Uz compinit
compinit

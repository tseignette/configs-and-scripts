# Your zshrc path here
ZSHRC_PATH=''

alias c='clear'
alias l='ls -GFh'
alias editrc="nano $ZSHRC_PATH"
alias reloadrc="source $ZSHRC_PATH"

export CLICOLOR=1
export LSCOLORS=bxFxCxDxBxegedabagaced
export VISUAL=nano
export EDITOR="$VISUAL"
export GREP_OPTIONS='--color=auto'

PROMPT='%F{14}%n%f@%F{11}%~%f$ '
autoload -U compinit
compinit

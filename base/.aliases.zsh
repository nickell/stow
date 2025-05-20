# vim: set ft=sh:

alias ..="cd ../"
alias asl="aws sso login"
alias ctl="systemctl --user"
alias d="nvim -c \"cd /home/chad/.dotfiles\""
alias db="nvim -c DBUI"
alias e="${(z)VISUAL:-${(z)EDITOR}}"
alias g="git"
alias gd="git diff"
alias gl="git log"
alias gs="git status"
alias l="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions -h"
alias ll="ls -aFhl"
alias m="make"
alias nr="npm run"
alias o="nvim -c \"cd /home/chad/Documents/notes/Notes\""
alias r=". ranger"
alias sctl="sudo systemctl"
alias se="sudoedit"
alias ssh='TERM=xterm-256color ssh'
alias ya="yadm"
alias z="__zoxide_zi"
alias ~="cd ~/"

# Functions
logs () {
    journalctl --user -f -o cat -u $1 | bunyan -o short
}

n () {
    if [ $# -eq 0 ]
    then
        nordvpn status;
    else
        nordvpn $*;
    fi
}

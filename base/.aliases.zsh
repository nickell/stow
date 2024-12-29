# vim: set ft=sh:

# alias c="clear"
alias ..="cd ../"
alias ~="cd ~/"
alias ctl="systemctl --user"
alias e="${(z)VISUAL:-${(z)EDITOR}}"
alias g="git"
alias gd="git diff"
alias gl="git log"
alias gs="git status"
alias ll="ls -aFhl"
# alias l="ls"
alias m="make"
alias nr="npm run"
alias r=". ranger"
alias sctl="sudo systemctl"
alias se="sudoedit"
alias ssh='TERM=xterm-256color ssh'
alias ya="yadm"
alias z="__zoxide_zi"
alias l="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions -h"
alias o="cd /home/chad/Documents/notes/Notes"

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

# vim: set fdm=marker fmr={{{,}}} fdl=0 ft=zsh:

# Used in ranger
export TERMCMD='alacritty'
export EDITOR=/usr/bin/nvim
export VISUAL=/usr/bin/nvim

# Used in git aliases for code reviews
export REVIEW_BASE='main'

# Make escape work immediately
export KEYTIMEOUT=1

# Pager use less
export PAGER="less -S"

export GOPATH="$HOME/go"

if [ -n "$DESKTOP_SESSION" ];then
    export SSH_AUTH_SOCK
fi

export NPM_CONFIG_PREFIX="$HOME/.local"

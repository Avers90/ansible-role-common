#!/usr/bin/env bash
## System aliases

## Colored ls and grep
if [[ -x /usr/bin/dircolors ]]; then
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

## File operations
alias ll='ls -alFh --time-style=long-iso'
alias la='ls -A'
alias l='ls -CF'
alias lsd='ls -l | grep "^d"'    # Directories only
alias lt='ls -lath'              # Sort by time
alias lr='ls -lR'                # Recursive

## Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

## System commands
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias psg='ps aux | grep'
alias mkdir='mkdir -pv'

## Network
alias myip='curl -s ifconfig.me'
alias ports='netstat -tulpn 2>/dev/null || ss -tulpn'
alias ping='ping -c 5'

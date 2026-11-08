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
alias cf='sed -e "/^\s*#/d" -e "/^\s*$/d" -e "/^\s*;/d"' # watch file without comments

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
alias myip='curl -s -4 ifconfig.me'
alias myip6='curl -s -6 ifconfig.me'
alias ipa='ip -c -br a'          # All addresses per interface, brief
alias ipa4='ip -c -br -4 a'      # IPv4 only
alias ipa6='ip -c -br -6 a'      # IPv6 only
alias ports='netstat -tulpn 2>/dev/null || ss -tulpn'
alias ping='ping -c 5'

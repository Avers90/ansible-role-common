#!/usr/bin/env bash
## Color settings

## Colors for ls
if [ -x /usr/bin/dircolors ]; then
  if [ -r ~/.dircolors ]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

## Colors for man pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # Begin blink
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # Begin bold
export LESS_TERMCAP_me=$'\E[0m'           # End mode
export LESS_TERMCAP_se=$'\E[0m'           # End standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # Begin standout-mode
export LESS_TERMCAP_ue=$'\E[0m'           # End underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # Begin underline

## Grep colors
export GREP_COLORS='mt=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'

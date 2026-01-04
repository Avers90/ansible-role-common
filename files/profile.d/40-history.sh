#!/usr/bin/env bash
## History settings

## History size
export HISTSIZE=100000
export HISTFILESIZE=200000

## History control
export HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates and commands starting with space
export HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history:bg:fg"

## Time format in history
export HISTTIMEFORMAT="%Y-%m-%d %T "

## Save history immediately after each command
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

## More history for root
if [ "$UID" -eq 0 ]; then
  export HISTSIZE=50000
  export HISTFILESIZE=100000
fi

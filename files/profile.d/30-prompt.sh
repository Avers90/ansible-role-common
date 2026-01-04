#!/usr/bin/env bash
## Custom prompt configuration

set_prompt() {
  local RED='\e[0;31m';
  local GREEN='\e[1;32m';
  local BROUN='\e[1;33m';
  local BLUE='\e[0;34m';
  local CYAN='\e[1;36m';
  local PURPLE='\e[0;35m';
  local _R='\e[0m';
  local IP_ADDR_SH=$(ip route get 1.1.1.1 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
  if [[ "$UID" -eq 0 ]]; then
    ## root - red
    PS1="[\[${RED}\]\u@\H\[${_R}\]|\[${CYAN}\]${IP_ADDR_SH}\[${_R}\]] \t (${BLUE}\w${_R})\n# "
  else
    ## regular user - green
    PS1="[\[${GREEN}\]\u@\H\[${_R}\]|\[${CYAN}\]${IP_ADDR_SH}\[${_R}\]] \t (${BLUE}\w${_R})\n# "
  fi
}

PROMPT_COMMAND=set_prompt

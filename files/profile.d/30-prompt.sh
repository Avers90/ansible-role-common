#!/usr/bin/env bash
## Custom prompt configuration

## Public IPv4 addresses of the host, comma-separated.
## The primary one (source address of the default route) goes first, then any
## other global IPv4 — e.g. a second IP on ens3:0 that clients connect to.
## Private (RFC1918), CGNAT, loopback and link-local are dropped, so VPN
## interface addresses (10.x) never show up. IPv6 is intentionally omitted.
## The primary is kept even if it is private, so a NAT-ed host still shows
## something.
_prompt_ips() {
  local primary
  primary=$(ip -4 route get 1.1.1.1 2>/dev/null | awk -F'src ' 'NR==1{split($2,a," ");print a[1]}')
  {
    echo "$primary"
    ip -4 -o addr show scope global 2>/dev/null | awk '{split($4,a,"/");print a[1]}' \
      | grep -Ev '^(10\.|127\.|169\.254\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.)'
  } | awk 'NF && !seen[$0]++' | paste -sd, -
}

set_prompt() {
  local RED='\e[0;31m';
  local GREEN='\e[1;32m';
  local BROUN='\e[1;33m';
  local BLUE='\e[0;34m';
  local CYAN='\e[1;36m';
  local PURPLE='\e[0;35m';
  local _R='\e[0m';
  local IP_ADDR_SH=$(_prompt_ips)
  ## Every colour code is wrapped in \[ \] — otherwise bash counts it as
  ## printable, miscalculates the prompt width and long lines wrap wrongly.
  if [[ "$UID" -eq 0 ]]; then
    ## root - red
    PS1="[\[${RED}\]\u@\H\[${_R}\]|\[${CYAN}\]${IP_ADDR_SH}\[${_R}\]] \t (\[${BLUE}\]\w\[${_R}\])\n# "
  else
    ## regular user - green
    PS1="[\[${GREEN}\]\u@\H\[${_R}\]|\[${CYAN}\]${IP_ADDR_SH}\[${_R}\]] \t (\[${BLUE}\]\w\[${_R}\])\n# "
  fi
}

PROMPT_COMMAND=set_prompt

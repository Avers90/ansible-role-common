#!/usr/bin/env bash
## Security settings

## Safe aliases (comment out if not needed)
alias rm='rm -I'  # -I prompts when deleting >3 files
alias cp='cp -i'
alias mv='mv -i'

## Prevent file overwrite with redirection
set -o noclobber

## Notify about failed login attempts
if [[ -n "$SSH_CLIENT" && -n "$PS1" ]]; then
  echo ""
  echo "Last login: $(last -2 "$USER" | head -2 | tail -1 | awk '{print $4" "$5" "$6" "$7}')"
  echo ""
fi

## Warning for root
if [[ "$UID" -eq 0 && -n "$PS1" ]]; then
  echo -e "\033[1;31m=== YOU ARE ROOT! BE CAREFUL! ===\033[0m"
  echo ""
fi

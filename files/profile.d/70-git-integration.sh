#!/usr/bin/env bash
## Git integration

## Check if git is installed
if command -v git &>/dev/null; then
  ## Git aliases
  alias gs='git status'
  alias ga='git add'
  alias gc='git commit'
  alias gcm='git commit -m'
  alias gco='git checkout'
  alias gb='git branch'
  alias gl='git log --oneline --graph --decorate'
  alias gp='git push'
  alias gpl='git pull'
  alias gd='git diff'
  alias gdc='git diff --cached'

  ## Git autocompletion if available
  if [ -f /usr/share/bash-completion/completions/git ]; then
      source /usr/share/bash-completion/completions/git
  elif [ -f /etc/bash_completion.d/git ]; then
      source /etc/bash_completion.d/git
  fi

  ## Pretty git log
  git_log_pretty() {
    git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all
  }

  ## Update all submodules
  git_update_all() {
    git pull && git submodule update --init --recursive
  }
fi

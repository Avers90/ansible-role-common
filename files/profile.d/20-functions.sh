#!/usr/bin/env bash
## User functions

## Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

## Search in history
hg() {
  history | grep -i "$1"
}

## Find file
ff() {
  find . -type f -iname "*$1*" 2>/dev/null
}

## Find dir
fd() {
  find . -type d -iname "*$1*" 2>/dev/null
}

## Search in files
fg() {
  grep -ri "$1" . --color=auto 2>/dev/null
}

## Extract archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2|*.tbz2) tar xjf "$1" ;;
      *.tar.gz|*.tgz)   tar xzf "$1" ;;
      *.tar.xz)         tar xJf "$1" ;;
      *.tar)            tar xf "$1"  ;;
      *.zip)            unzip "$1"   ;;
      *.rar)            unrar x "$1" ;;
      *.7z)             7z x "$1"    ;;
      *.gz)             gunzip "$1"  ;;
      *.bz2)            bunzip2 "$1" ;;
      *.Z)              uncompress "$1" ;;
      *.deb)            ar x "$1" ;;
      *)                echo "Unknown archive format: $1" ;;
    esac
  else
    echo "File not found: $1"
  fi
}

## Directory sizes
ds() {
  du -h --max-depth=1 "${1:-.}" | sort -h
}

## Create file backup
bak() {
  cp "$1" "$1.bak"
}

## Show IP info (own IP or specified)
ipa() {
  curl -s "https://ifconfig.co/json?ip=$1" | jq 'del(.user_agent)'
}

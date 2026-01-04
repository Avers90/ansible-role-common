#!/usr/bin/env bash
## Basic bash options

## Exit if not interactive session
[[ -z "$PS1" ]] && return

## Enable window size check
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dotglob
shopt -s nocaseglob
shopt -s globstar      # Recursive glob **
shopt -s extglob       # Extended glob
shopt -s histappend    # Append to history, don't overwrite

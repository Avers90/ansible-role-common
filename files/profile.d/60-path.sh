#!/usr/bin/env bash
## PATH settings

## Add system paths if not present
for path in /usr/local/bin /usr/local/sbin /snap/bin; do
  if [[ ":$PATH:" != *":$path:"* ]] && [ -d "$path" ]; then
    export PATH="$path:$PATH"
  fi
done

## Add user paths
if [[ ":$PATH:" != *":$HOME/bin:"* ]] && [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

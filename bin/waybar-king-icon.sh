#!/usr/bin/env bash
S="$HOME/.king-kusaila/repondeur.state"
if [[ -f "$S" && "$(cat "$S" 2>/dev/null)" == "on" ]]; then
  echo "$HOME/.local/share/king-kusaila/king-icon-on.png"
else
  echo "$HOME/.local/share/king-kusaila/king-icon-off.png"
fi

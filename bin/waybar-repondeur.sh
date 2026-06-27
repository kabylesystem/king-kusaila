#!/usr/bin/env bash
# Module Waybar du répondeur Signal de King. 🔴 coupé / 🟢 actif. Clic = bascule.
STATE="$HOME/.king-kusaila/repondeur.state"
s="off"; [[ -f "$STATE" ]] && s="$(cat "$STATE" 2>/dev/null)"
if [[ "$s" == "on" ]]; then
  printf '{"text":"🟢 répondeur","tooltip":"Répondeur Signal ACTIF — clic pour couper","class":"on"}\n'
else
  printf '{"text":"📭","tooltip":"Répondeur Signal coupé — clic pour activer","class":"off"}\n'
fi

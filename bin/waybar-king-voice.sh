#!/usr/bin/env bash
# Module Waybar "KING" = cockpit du travail BACKGROUND (Super+V).
#   texte = état voix/mission en direct (REC / ASR / KING / ✅ / ⚠️ / 👑 idle)
#   survol = menu : mission en cours / dernière mission + fini/échec
#   clic = fenêtre statut + dernier rapport complet
ROOT="$HOME/.king-kusaila"
SD="${XDG_RUNTIME_DIR:-/tmp}/king-kusaila"
SF="$SD/voice-status"; [[ -f "$SF" ]] || SF="/tmp/king-kusaila-$USER/voice-status"

# --- résumé des missions background (le menu) ---
nrun="$(pgrep -fc '[c]laude --print' 2>/dev/null)"; [[ "$nrun" =~ ^[0-9]+$ ]] || nrun=0
job="$(ls -td "$ROOT"/jobs/*/ 2>/dev/null | head -1)"
if [[ "$nrun" -gt 0 ]]; then
  bg="<span color='#c9a6ff'>🟣 ${nrun} mission(s) en cours…</span>"
elif [[ -n "$job" ]]; then
  m="$(grep -m1 -- '- mission:' "$job/STATUS.md" 2>/dev/null | sed 's/.*- mission: *//' | cut -c1-44)"
  code="$(grep -m1 -E '^- exit_code:' "$job/STATUS.md" 2>/dev/null | sed 's/.*: *//')"
  if [[ "$code" == "0" ]]; then badge="<span color='#3ddc84'>✅ fini</span>"
  elif [[ -n "$code" ]]; then badge="<span color='#ff5d6c'>❌ échec</span>"
  else badge="<span color='#c9a6ff'>… en cours</span>"; fi
  bg="dernière : ${m}  ${badge}"
else
  bg="aucune mission"
fi

# --- état voix/mission en direct -> texte du bouton ---
state=idle; label=""; ts=0
[[ -f "$SF" ]] && IFS='|' read -r state label ts < "$SF" || true
age=$(( $(date +%s) - ${ts:-0} ))
case "${state:-idle}" in
  recording)    text="🔴 REC"; cls="recording";;
  transcribing) text="✍️ ASR"; cls="transcribing";;
  king)         text="👑 KING"; cls="king";;
  done)   if (( age>4 )); then rm -f "$SF"; text="👑"; cls="idle"; else text="✅"; cls="done"; fi;;
  error)  if (( age>6 )); then rm -f "$SF"; text="👑"; cls="idle"; else text="⚠️"; cls="error"; fi;;
  *)            text="👑"; cls="idle";;
esac

tt="$(printf '<b>\U0001F451 King — travail background</b>\nVoix : %s\nMission : %s\n<small>──────────────</small>\n<small><i>clic : statut et dernier rapport complet</i></small>' "${state:-idle}" "$bg")"
jq -nc --arg t "$text" --arg c "$cls" --arg tt "$tt" '{text:$t, class:$c, tooltip:$tt}'

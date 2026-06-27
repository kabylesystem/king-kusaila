#!/usr/bin/env bash
# Module Waybar "King Kusaila" : couronne verte (répondeur actif) / rouge (coupé).
# Survol = panneau d'infos (tooltip). Clic = bascule répondeur. Clic droit = statut.
ROOT="$HOME/.king-kusaila"
STATE="$ROOT/repondeur.state"
on=0; [[ -f "$STATE" && "$(cat "$STATE" 2>/dev/null)" == "on" ]] && on=1

# dernière mission
job="$(ls -td "$ROOT"/jobs/*/ 2>/dev/null | head -1)"
jline=""
if [[ -n "$job" ]]; then
  miss="$(grep -m1 -- '- mission:' "$job/STATUS.md" 2>/dev/null | sed 's/.*- mission: *//' | cut -c1-46)"
  stat="$(grep -m1 -E '^- (status|exit_code):' "$job/STATUS.md" 2>/dev/null | sed 's/^- *//')"
  [[ -n "$miss" ]] && jline="dernière mission : ${miss} — ${stat}"
fi

if [[ "$on" == 1 ]]; then
  icon="<span color='#3ddc84' size='large'>👑</span>"
  rep="<span color='#3ddc84'><b>🟢 ACTIF</b></span>"
  cls="on"
else
  icon="<span color='#ff5d6c' size='large'>👑</span>"
  rep="<span color='#ff5d6c'><b>🔴 coupé</b></span>"
  cls="off"
fi

tt="<b>👑 King Kusaila</b>
Répondeur Signal : ${rep}
<small>délai 1–3 min · contacts : Leticia</small>"
[[ -n "$jline" ]] && tt="${tt}
<small>${jline}</small>"
tt="${tt}

<small><i>clic : activer/couper · clic droit : statut &amp; rapport</i></small>"

jq -nc --arg t "$icon" --arg tt "$tt" --arg c "$cls" '{text:$t, tooltip:$tt, class:$c}'

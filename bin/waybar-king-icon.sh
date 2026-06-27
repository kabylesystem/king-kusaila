#!/usr/bin/env bash
# Module image#king de Waybar.
#   ligne 1  = chemin de l'avatar (vert = répondeur actif, rouge = coupé)
#   lignes + = tooltip = LE MENU affiché au survol (persistant tant qu'on survole)
ROOT="$HOME/.king-kusaila"
STATE="$ROOT/repondeur.state"
D="$HOME/.local/share/king-kusaila"
on=0; [[ -f "$STATE" && "$(cat "$STATE" 2>/dev/null)" == "on" ]] && on=1

# --- WATCHDOG : si répondeur ON mais boucle morte -> relance (vert = ça répond) ---
if [[ "$on" == 1 ]]; then
  p="$(cat "$ROOT/repondeur.loop.pid" 2>/dev/null || true)"
  { [[ -n "$p" ]] && kill -0 "$p" 2>/dev/null; } || setsid -f "$HOME/.local/bin/king-repondeur" __heal >/dev/null 2>&1
fi

# --- ligne 1 : l'icône selon l'état ---
[[ "$on" == 1 ]] && echo "$D/king-icon-on.png" || echo "$D/king-icon-off.png"

# --- état répondeur (coloré) ---
if [[ "$on" == 1 ]]; then
  rep="<span color='#3ddc84'><b>🟢 ACTIF</b></span>"
else
  rep="<span color='#ff5d6c'><b>🔴 coupé</b></span>"
fi

# --- missions background ---
job="$(ls -td "$ROOT"/jobs/*/ 2>/dev/null | head -1)"
nrun="$(pgrep -fc '[c]laude --print' 2>/dev/null)"; [[ "$nrun" =~ ^[0-9]+$ ]] || nrun=0
if [[ "$nrun" -gt 0 ]]; then
  miss="<span color='#c9a6ff'>🟣 ${nrun} mission(s) en cours…</span>"
elif [[ -n "$job" ]]; then
  m="$(grep -m1 -- '- mission:' "$job/STATUS.md" 2>/dev/null | sed 's/.*- mission: *//' | cut -c1-40)"
  st="$(grep -m1 -E '^- (status|exit_code):' "$job/STATUS.md" 2>/dev/null | sed 's/^- *//')"
  miss="dernière : ${m} <i>(${st})</i>"
else
  miss="aucune mission"
fi

# --- le menu (tooltip, pango) ---
printf '<b>👑 King Kusaila</b>\n'
printf 'Répondeur Signal : %s\n' "$rep"
printf '<small>délai 1–3 min · contact : Leticia</small>\n'
printf 'Missions background : %s\n' "$miss"
printf '<small>──────────────</small>\n'
printf '<small><i>clic : activer / couper le répondeur</i></small>\n'
printf '<small><i>clic droit : statut &amp; dernier rapport</i></small>'

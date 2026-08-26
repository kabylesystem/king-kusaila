#!/usr/bin/env bash

hwmon_by_name() {
  local h
  for h in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$h/name" 2>/dev/null)" = "$1" ] && { printf '%s' "$h"; return 0; }
  done
  return 1
}

cpu_hwmon="$(hwmon_by_name coretemp)"
temp=$(( $(cat "${cpu_hwmon:-/nonexistent}/temp1_input" 2>/dev/null || echo 0) / 1000 ))
cpu_psi=$(awk -F'[= ]' '/^some/{printf "%.0f", $3; exit}' /proc/pressure/cpu 2>/dev/null || echo 0)
io_psi=$(awk -F'[= ]' '/^full/{printf "%.0f", $3; exit}' /proc/pressure/io 2>/dev/null || echo 0)
load=$(awk '{printf "%.1f", $1}' /proc/loadavg)
cores=$(nproc)
load_pct=$(awk -v l="$load" -v c="$cores" 'BEGIN{printf "%.0f", l/c*100}')

score=0
[ "$cpu_psi" -ge 12 ] && score=1
[ "$cpu_psi" -ge 28 ] && score=2
[ "$io_psi" -ge 8 ] && score=$(( score > 1 ? score : 1 ))
[ "$io_psi" -ge 20 ] && score=2
[ "$temp" -ge 88 ] && score=$(( score > 1 ? score : 1 ))
[ "$temp" -ge 96 ] && score=2
[ "$load_pct" -ge 55 ] && score=$(( score > 1 ? score : 1 ))

bug=$(printf '\uf188')
case "$score" in
  2) icon="$bug FIX"; cls="lag"; state="ÇA LAG" ;;
  1) icon="$bug"; cls="tendu"; state="TENDU" ;;
  *) icon="$bug"; cls="calme"; state="CALME" ;;
esac

last=""
report="${XDG_RUNTIME_DIR:-/tmp}/naly-antibug/last.txt"
if [ -f "$report" ]; then
  body="$(head -3 "$report" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/"/\&quot;/g; s/\\/\\\\/g' | sed ':a;N;$!ba;s/\n/\\n/g')"
  [ -n "$body" ] && last="\\n\\n<b>Dernier passage</b>\\n${body}"
fi

tooltip="<b>Anti-bug · ${state}</b>\n${temp}°C · charge ${load} (${load_pct}%)\nCPU bloqué ${cpu_psi}% · disque bloqué ${io_psi}%\n\n CLIC GAUCHE → diagnostiquer et corriger\n CLIC DROIT  → historique thermique${last}"

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$icon" "$cls" "$tooltip"

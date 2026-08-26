#!/usr/bin/env bash
# waybar-thermal.sh — module Waybar : sélecteur de profil thermique de naly.
# Affiche : thermomètre + NOM du mode + temp CPU, pour être clairement cliquable.
# Clic gauche = cycle (silencieux -> equilibre -> perf) · clic droit = silencieux.

prof=$(/usr/local/bin/naly-thermal-profile get 2>/dev/null || echo equilibre)

hwmon_by_name() {
  local want="$1" h
  for h in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$h/name" 2>/dev/null)" = "$want" ] && { printf '%s' "$h"; return 0; }
  done
  return 1
}

cpu_hwmon="$(hwmon_by_name coretemp)"
fan_hwmon="$(hwmon_by_name cros_ec)"
[ -n "$fan_hwmon" ] || fan_hwmon="$(hwmon_by_name acpi_fan)"

temp_mc=$(cat "${cpu_hwmon:-/nonexistent}/temp1_input" 2>/dev/null)
[ -z "$temp_mc" ] && temp_mc=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | sort -rn | head -1)
temp_now=$(( ${temp_mc:-0} / 1000 ))
rpm=$(cat "${fan_hwmon:-/nonexistent}/fan1_input" 2>/dev/null || echo 0)

hist="${XDG_RUNTIME_DIR:-/tmp}/naly-thermal-history"
printf '%s\n' "$temp_now" >> "$hist"
tail -n 20 "$hist" > "$hist.tmp" 2>/dev/null && mv -f "$hist.tmp" "$hist"
temp=$(awk '{s+=$1; n++} END{printf "%d", (n ? s/n : 0)}' "$hist")
[ "${temp:-0}" -eq 0 ] && temp=$temp_now

case "$prof" in
  silencieux) picon=""; label="Silencieux"; cls="silencieux" ;;
  perf)       picon=""; label="Perf";       cls="perf" ;;
  *)          picon=""; label="Équilibré";  cls="equilibre" ;;
esac

# thermomètre coloré selon la chaleur
if   [ "$temp" -ge 90 ]; then cls="critical"
elif [ "$temp" -ge 82 ]; then cls="warning"
fi

# Texte explicite et cliquable : thermomètre + mode + temp
text="${picon} ${label} ${temp}°"
tooltip="🌡 Profil thermique : ${label}  (moyenne ${temp}°C · pic ${temp_now}°C · ventilo ${rpm} RPM)\n\n CLIC GAUCHE → mode suivant (Silencieux → Équilibré → Perf)\n CLIC DROIT  → Silencieux direct\n\n🟢 Silencieux : frais &amp; muet (18/30W)\n⚖️ Équilibré : pleine puissance soutenue (28/50W)\n🚀 Perf : la bête lâchée (35/64W)"

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$cls" "$tooltip"

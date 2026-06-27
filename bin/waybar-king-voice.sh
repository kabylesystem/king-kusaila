#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/king-kusaila"
STATE_FILE="$STATE_DIR/voice-status"
if [[ ! -f "$STATE_FILE" ]]; then
  STATE_FILE="/tmp/king-kusaila-$USER/voice-status"
fi

json() {
  local text="$1"
  local class="$2"
  local tooltip="$3"
  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
    "$text" "$class" "$tooltip"
}

if [[ ! -f "$STATE_FILE" ]]; then
  json "MIC" "idle" "King voice idle"
  exit 0
fi

IFS='|' read -r state label ts < "$STATE_FILE" || true
now="$(date +%s)"
age=$((now - ${ts:-0}))

case "${state:-idle}" in
  recording)
    json "REC" "recording" "${label:-Recording}"
    ;;
  transcribing)
    json "ASR" "transcribing" "${label:-Transcribing}"
    ;;
  king)
    json "KING" "king" "${label:-King Kusaila}"
    ;;
  done)
    if (( age > 4 )); then
      rm -f "$STATE_FILE"
      json "MIC" "idle" "King voice idle"
    else
      json "OK" "done" "${label:-Done}"
    fi
    ;;
  error)
    if (( age > 6 )); then
      rm -f "$STATE_FILE"
      json "MIC" "idle" "King voice idle"
    else
      json "!" "error" "${label:-Error}"
    fi
    ;;
  *)
    json "MIC" "idle" "King voice idle"
    ;;
esac

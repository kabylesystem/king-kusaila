# King Kusaila Harness

King Kusaila is the local voice layer for this CachyOS/Hyprland laptop.

## Current Controls

- `SUPER+C`: voice dictation toggle.
  - First press starts recording.
  - Second press stops, transcribes locally with Whisper, copies to clipboard, types into the focused window, and appends to the daily voice log.

- `SUPER+V`: voice mission toggle.
  - First press starts recording a mission.
  - Second press stops, transcribes locally, creates a job folder, and opens Claude Code as King Kusaila with bypass permissions.
  - If the mission contains "background", "arriere-plan", "arrière-plan", "cache-toi", or "silent", it runs hidden and notifies on completion.

## Core Principle

Claude Code remains the intelligence and execution engine. King Kusaila is the OS harness around it:

- voice input
- job folders
- durable logs
- skills
- notifications
- future TTS

King Kusaila is intended to be the laptop's Jarvis-style operator: dictate an idea, system tweak, project bootstrap, investigation, or repair, and Claude Code opens with the right mission and enough local permissions to do the work.

## Directory Layout

- `jobs/`: Claude Code missions launched by voice.
- `voice-notes/`: daily dictation logs.
- `skills/`: reusable operating procedures.
- `assets/`: future voice/personality/image assets.
- `LOG.md`: global mission history.

## Safety

The mission runner currently uses Claude Code with `--dangerously-skip-permissions`.
Use it for trusted local work. Do not dictate destructive system tasks casually.

Future safety layers:

- Btrfs snapshot before system changes.
- Per-job allow/deny rules.
- Destructive-command confirmation.
- Desktop overlay showing active jobs.
- TTS completion summary.

## Sources / Model Choice

The local transcription stack uses `whisper.cpp` with OpenAI's `whisper-large-v3-turbo` weights converted for GGML.

Reason:

- `large-v3-turbo` is multilingual, supports auto language detection, and is designed to be much faster than full `large-v3` with only minor quality loss.
- `whisper.cpp` is the lightweight C/C++ path that fits a Linux desktop/Hyprland workflow without Python services.

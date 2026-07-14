# king kusaila

A laptop operated by voice. Not a chat window: an operator that listens, understands, and **acts**, by handing the machine to Claude Code with full autonomy.

Named after Kusaila, the Amazigh king who resisted an empire.

## The two gestures

| Shortcut | What it does |
|-----------|------|
| **`Super+C`** | **Dictation** anywhere: records, transcribes (gpt-4o-transcribe), types the text into the focused window. Clipboard is preserved, start/stop is deterministic. |
| **`Super+V`** | **Voice mission**: you speak a task, it transcribes, then launches Claude Code either in the background (silent, notifies you when done) or in a visible terminal. |
| **`Super+Shift+V`** | **Text mission**: same pipeline, paste-friendly, for long prompts. |
| **`Super+Q`** | **Cancel** a running mission. |

Recording is a toggle: press once to start, press again to stop and run.

## Architecture

```
A. Hotkeys          Hyprland userprefs.conf -> Super+C / Super+V
B. Audio capture    pw-record (internal mic, anti-clipping)
C. Speech to text   OpenAI gpt-4o-transcribe, with a local whisper.cpp fallback
                    anti-hallucination gate: silence or clipping types nothing
D. Visual layer     GTK layer-shell avatar overlay, a background/CLI chooser, Waybar status
E. Agent execution  a durable job -> claude, background (--print + notifications) or visible terminal
```

Every mission creates a durable job in `~/.king-kusaila/jobs/<date>-<slug>/` containing the mission, its status, the full log, and a final report.

## Install

```bash
./install.sh                       # symlinks bin/* into ~/.local/bin
cp config/openai.env.example ~/.config/king-kusaila/openai.env
chmod 600 ~/.config/king-kusaila/openai.env      # then fill in OPENAI_API_KEY
cat hypr/userprefs-king.conf >> ~/.config/hypr/userprefs.conf && hyprctl reload
```

Dependencies: `pipewire` (pw-record), `wtype`, `wl-clipboard`, `jq`, `ffmpeg`, `python-gobject`, `gtk3`, `gtk-layer-shell`, `dunst`, `whisper.cpp` (fallback), and `claude` (Claude Code).

Built for CachyOS and Hyprland; the pieces are small enough to port elsewhere.

## Settings

Optional environment variables: `KING_MIN_AUDIO_SEC` (0.35), `KING_MIN_PEAK_DB` (-40), `KING_CHOICE_TIMEOUT` (10), `KING_OPENAI_TRANSCRIBE_MODEL`, `KING_RECORD_SOURCE`, `KING_TRANSCRIBE_BACKEND=local`.

## Why

I wanted to know what it feels like when the computer actually listens, instead of waiting for someone to sell that feeling to me.

More on [nabtiylan.com](https://nabtiylan.com/projects/king-kusaila).

# 👑 King Kusaila

L'opérateur IA vocal local du laptop (CachyOS / Hyprland). Pas un chat : un **Jarvis** qui
écoute, comprend, et **fait** — en lançant Claude Code avec autonomie maximale.

## Les deux gestes

| Raccourci | Rôle |
|-----------|------|
| **`Super+C`** | **Dictée** vocale globale → transcrit (gpt-4o-transcribe) et tape le texte dans la fenêtre active + journalise. Qualité quasi instantanée, anti-hallucination. |
| **`Super+V`** | **Mission** vocale → King apparaît, tu parles une tâche, il transcrit, puis lance Claude Code en **background** (silencieux) ou **CLI** (terminal visible). |

Toggle : 1er appui = enregistre, 2e appui = stoppe et lance.

## Architecture (5 couches)

```
A. Hotkeys Hyprland     userprefs.conf  ->  Super+C / Super+V
B. Capture audio        pw-record (mic interne, anti-clipping)
C. ASR                  voice-transcribe -> OpenAI gpt-4o-transcribe (+ fallback whisper.cpp local)
                        gate anti-hallucination (silence/clip -> rien tapé) + garde anti-écho
D. UX visuelle          king-kusaila-visuald (avatar overlay GTK layer-shell, daemon chaud)
                        king-kusaila-choice (chooser background/CLI, auto-dismiss 10s)
                        king-voice-status -> Waybar
E. Exécution agent      king-kusaila-toggle -> job durable -> claude (bypass permissions)
                        background = claude --print + notifs ; CLI = kitty sur l'écran courant
```

Chaque mission crée un **job durable** dans `~/.king-kusaila/jobs/<date>-<slug>/`
(`mission.txt`, `STATUS.md`, `claude.log`, `FINAL.md` = le rapport).

## Installation

```bash
./install.sh                       # symlink bin/* -> ~/.local/bin (backup si existant)
cp config/openai.env.example ~/.config/king-kusaila/openai.env && chmod 600 ~/.config/king-kusaila/openai.env
# -> remplir OPENAI_API_KEY
cat hypr/userprefs-king.conf >> ~/.config/hypr/userprefs.conf && hyprctl reload
```

Dépendances : `pipewire` (pw-record), `wtype`, `wl-clipboard`, `jq`, `ffmpeg`, `python-gobject`
+ `gtk3` + `gtk-layer-shell`, `dunst`, `whisper.cpp` (fallback), `claude` (Claude Code).

## Réglages (env, optionnels)

`KING_MIN_AUDIO_SEC` (0.35) · `KING_MIN_PEAK_DB` (-40) · `KING_CHOICE_TIMEOUT` (10) ·
`KING_OPENAI_TRANSCRIBE_MODEL` · `KING_RECORD_SOURCE` · `KING_TRANSCRIBE_BACKEND=local`.

## Vision / roadmap — King qui FAIT

Le but : un opérateur qui agit dans le monde réel. Tout ce que King peut scripter, il peut le faire.

- [x] **Fichiers** (`~/future/saas`, le système) — déjà, via bash + bypass.
- [x] **Anki** — via AnkiConnect (`~/.local/bin/anki-add.py`).
- [x] **Brave / web** — via Playwright (déjà installé).
- [ ] **Signal** — à câbler : `signal-cli` lié au compte → `king-notify-signal`.
- [ ] **Mail** — à câbler : `msmtp` + app password Gmail → `king-send-mail`.
- [ ] Rapport de fin enrichi (notif + résumé) — en place côté background.

> Détail complet du chantier et de l'historique : [`docs/kusaila-boss.md`](docs/kusaila-boss.md).

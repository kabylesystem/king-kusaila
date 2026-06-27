# Kusaila Boss

Document de relais pour reprendre le chantier "King Kusaila" avec Codex/Claude.

Date de reference: 2026-06-27  
Machine: CachyOS/Arch + Hyprland + HyDE, shell utilisateur fish, scripts ecrits en bash/python.  
Utilisateur: naly / Ylan, home actuel `/home/kusaila`.

## Resume ultra court

On a transforme le laptop en debut de couche IA vocale locale:

- `Super+C` = dictee vocale: enregistre, transcrit, copie dans le presse-papier, tape dans la fenetre active, journalise.
- `Super+V` = mission vocale King Kusaila: enregistre une mission, transcrit, affiche l'avatar King Kusaila, demande `background` ou `Claude Code`, puis lance Claude Code avec permissions bypass et un dossier de job durable.
- King Kusaila a maintenant un overlay anime centre sur l'ecran, garde son daemon chaud en memoire, et ne spawn plus lentement a chaque hotkey.
- Les jobs sont traces dans `~/.king-kusaila/jobs/`.
- Les assets animes sont dans `~/.king-kusaila/assets/`.
- Hyprland branche les hotkeys dans `~/.config/hypr/userprefs.conf`.

Le fichier de conversation Codex principal ou tout a ete parametre:

```bash
codex resume 019f0230-9aa3-7123-b595-6e036295d994
```

Fichier brut:

```text
/home/kusaila/.codex/sessions/2026/06/26/rollout-2026-06-26T06-29-27-019f0230-9aa3-7123-b595-6e036295d994.jsonl
```

Sessions Claude liees:

```text
/home/kusaila/.claude/projects/-home-kusaila/8b68af96-8957-485f-96fb-28e9e4fb10fa.jsonl
/home/kusaila/.claude/projects/-home-kusaila/b1eea509-4133-433a-ba8d-85c667509fbf.jsonl
```

## Sessions retrouvees et scrutees

Cette section est la partie "archeologie" du relais. Elle ne resume pas seulement l'etat final: elle explique comment on en est arrives a King Kusaila, avec les chemins de sessions, les virages de discussion, les decisions implicites, les erreurs reparees, et les preuves a retrouver si un agent doit continuer.

### Carte des sessions sources

| Source | Chemin | Taille / lignes | Role |
|---|---|---:|---|
| Codex principale | `/home/kusaila/.codex/sessions/2026/06/26/rollout-2026-06-26T06-29-27-019f0230-9aa3-7123-b595-6e036295d994.jsonl` | `12,397,090` octets / `3508` lignes | Session ou King Kusaila, `Super+C`, `Super+V`, ASR OpenAI/local, overlay, chooser, daemon, Hyprland ont ete construits. |
| Claude liee 1 | `/home/kusaila/.claude/projects/-home-kusaila/8b68af96-8957-485f-96fb-28e9e4fb10fa.jsonl` | `6,173,504` octets / `2546` lignes | Contexte large CachyOS/HyDE, reprise Claude, services, memories, environnement, autres scripts systeme. |
| Claude liee 2 | `/home/kusaila/.claude/projects/-home-kusaila/b1eea509-4133-433a-ba8d-85c667509fbf.jsonl` | `3,784,585` octets / `246` lignes | Suite Hyprland/workspaces/wallpaper/launcher, avec `bypassPermissions`, backups de `userprefs.conf` et contexte final de config. |

Commande de reprise Codex:

```bash
codex resume 019f0230-9aa3-7123-b595-6e036295d994
```

Commandes de reprise Claude utiles:

```bash
claude --continue
claude --resume
claude --resume 8b68af96-8957-485f-96fb-28e9e4fb10fa
claude --resume b1eea509-4133-433a-ba8d-85c667509fbf
```

Notes d'extraction:

- Les timestamps des JSONL Codex sont en UTC. Le 26 juin 2026 a ete travaille en Europe/Paris, donc ajouter +2h pour l'heure locale.
- J'ai fabrique deux extracts temporaires pendant ce relais:
  - `/tmp/codex-king-timeline.txt`
  - `/tmp/claude-king-timeline.txt`
- Ces extracts sont pratiques pour grepper vite, mais la source durable reste les JSONL ci-dessus.

### Ce que la session Codex raconte vraiment

La session Codex ne commence pas par King. Elle commence par securiser la machine apres migration Ubuntu -> CachyOS, puis elle glisse vers l'idee "AI OS", puis naly recadre vers un truc beaucoup plus concret: utiliser Claude Code paye au plan, et construire autour de lui une couche vocale/OS.

#### Phase 0: etat machine et rescue avant King

La session demarre dans `/home/kusaila`, sur kernel CachyOS:

```text
Linux kusaila 7.1.1-2-cachyos ... x86_64 GNU/Linux
```

Le disque montre:

- `nvme0n1p2` ext4 monte en `/mnt/ubuntu`.
- `nvme0n1p3` btrfs utilise par CachyOS, `/home/kusaila`, `/`, `/var/log`, etc.

Avant de toucher au projet King, Codex a verifie que l'ancien Ubuntu etait bien exploitable et que les donnees importantes etaient la. Points prouves dans la session:

- `/home/kusaila/future` existe deja et fait `45G`.
- L'ancien `/mnt/ubuntu/home/user/future` faisait aussi `45G`.
- A `maxdepth 3`, comparaison old/new: `0 fichier` et `0 dossier` manquant dans `future`.
- `~/42` cote ancien Ubuntu faisait `5.6G`.
- `math` cote Ubuntu faisait `22M`.
- `Downloads/mac os` faisait environ `7.3G` apres copie/verif, avec `10408` fichiers, `2060` dossiers, `0 missing`.
- Plusieurs configs ont ete recuperees ou sauvees:
  - `.claude`
  - `.codex` vers `/home/kusaila/ubuntu-rescue-configs/.codex` parce que le live `.codex` etait special/monte autrement
  - `.agents` vers `/home/kusaila/ubuntu-rescue-configs/.agents`
  - `.nvm`
  - `.gemini`
  - `.codeium`
  - `.claude-profiles`
  - `.auto-claude`
  - `.gnupg`
  - `.vim`
  - `.oh-my-zsh`
  - `.openclaw`
  - `.openclaw-telegram-ylan`
  - `.config/gh`
  - `.config/nvim`
  - `.config/ghostty`
  - `.config/btop`
  - `bin`
  - `pyenv`
  - `kabyle_vocab`
  - `kabylesystem`
  - `cachyos-migration`

Anki a aussi ete traite dans la session:

- `anki 26.05-1.1` installe via pacman/CachyOS.
- Anciennes donnees Anki trouvees: `~/.local/share/Anki2` environ `2.7M`.
- Ancien dossier `~/anki` copie puis finalement range dans `/home/kusaila/ubuntu-rescue-configs/old-anki/` quand naly a voulu repartir propre.
- Le fichier `silicon_valley_anki_deck.xlsx` est preserve dans ce vieux dossier.

Cette phase explique pourquoi les scripts King ont ensuite ete poses directement dans le home actif: la machine etait consideree comme assez saine pour continuer.

#### Phase 1: fausse piste "AI job system"

Codex a d'abord propose un systeme de jobs/agents:

- `jobs/`
- `state.json`
- `systemd --user`
- `job run`
- agents specialises
- recherche locale
- router local/cloud

naly a recadre:

```text
mais ca vrmt je peux ouvrir un claude code et il le fait
jai pas dit claude jai dit claude code
```

Le point essentiel: ne pas reconstruire Claude Code. Claude Code est deja l'agent de travail. Le PC doit juste devenir un cockpit qui prepare, lance, reprend et pilote Claude Code.

#### Phase 2: decision plan-first / Claude Code comme moteur

naly explicite le raisonnement cout:

```text
je prefere toujours utiliser claude code et ses agents (et sub agents?)
parce que du coup je paye au plan et que ca revient a presque rien
alors que toi ca demanderait une solution API genre harness hermes, openclaw ou autre
```

Decision gravee dans la session:

- L'intelligence principale doit rester Claude Code.
- Le plan Claude/Claude Code est l'avantage economique.
- Les API au token ne doivent pas devenir le runner principal.
- L'OS/Hyprland sert a orchestrer, pas a remplacer.

Formule importante de la session:

```text
faire de CachyOS/Hyprland le meilleur cockpit Claude Code possible.
Pas remplacer Claude Code. L'orchestrer.
```

C'est la racine mentale de King Kusaila.

#### Phase 3: "whisper partout" -> `Super+C`

naly lance:

```text
bah whisper partout
```

Puis il precise la vision:

```text
a chaque fois que ya une entree texte qq part super + c
... qualite openai reconnaissance vocale presque parfaite
... reconnait la langue FR et EN
... AUCUN delais
... si je lutilise pas dans un champ de texte ... une appli note ...
```

Decision produit:

- `Super+C` = dictee globale.
- Premier appui: start recording.
- Deuxieme appui: stop, transcribe, paste/type.
- Si pas de champ texte, garder quand meme une trace dans une note datee.
- FR/EN auto.
- UX sans grosse fenetre.
- Feedback minimal via Waybar/statut/overlay, pas des notifications moches.

Implementation issue de cette phase:

- `/home/kusaila/.local/bin/voice-dictate-toggle`
- `/home/kusaila/.local/bin/voice-transcribe`
- `/home/kusaila/.local/bin/voice-transcribe-local`
- plus tard `/home/kusaila/.local/bin/voice-transcribe-openai`
- notes dans `~/.king-kusaila/voice-notes/YYYY-MM-DD.md`

#### Phase 4: naissance de `Super+V` / King Kusaila

La phrase cle de naly est celle-ci:

```text
quand je fais super + v ... parler a genre king kusaila l'IA de mon pc
qui va lancer une loop sur claude code dangerously skip permissions
tant que ce que jai pas demande nest pas fini ... il continue de bosser
et il me previent uniquement quand c fini
on pourrait mm lui donner une voix dans le futur avec du TTS
fait la premiere idee puis la deuxieme et prend whisper ... le truc HYPER bien
```

Tout King vient de la:

- `Super+V` n'est pas une dictee.
- C'est une mission vocale.
- La mission est transcrite puis transformee en job durable.
- Claude Code doit etre lance avec `--dangerously-skip-permissions`.
- L'agent doit continuer jusqu'a fini/bloque, pas revenir toutes les 2 minutes.
- L'utilisateur ne veut etre prevenu qu'a la fin ou en vrai blocage.
- Future extension: TTS/voix pour King, mais pas fait dans cette session.

Codex a donc propose deux commandes systeme:

- `voice-dictate` / `voice-dictate-toggle` pour `Super+C`.
- `king-kusaila` / `king-kusaila-toggle` pour `Super+V`.

#### Phase 5: paquets et outils installes/verifies

La session verifie les outils presents:

- `hyprctl`
- `wl-copy`
- `notify-send`
- `pw-record`
- `parec`
- `arecord`
- `python3`
- `uv`
- `claude`

Puis elle installe/integre:

- `whisper-cpp-vulkan`
- `wtype`
- `jq`
- plus tard usage de `mpv`, `ffmpeg`, `ImageMagick`, `gtk-layer-shell`, GTK3/PyGObject.

Binaire Whisper trouve via Arch/CachyOS:

```text
/usr/bin/whisper-cli
/usr/bin/whisper-server
/usr/bin/whisper-bench
```

Premier choix ASR local:

- `large-v3-turbo`
- chemin vise: `~/.local/share/whisper.cpp/models/ggml-large-v3-turbo.bin`
- raison: meilleur compromis local gratuit/qualite/vitesse.

Puis pivot ASR:

- local pur pas assez bon/rapide pour "qualite OpenAI presque parfaite".
- OpenAI `gpt-4o-transcribe` devient backend par defaut si `OPENAI_API_KEY` existe.
- local reste fallback.

Preuve dans la session:

- apres test, `Super+C` / `Super+V` utilisent `gpt-4o-transcribe`.
- les vocaux Signal de 13s a 29s sortent en environ `1.3s` a `3.0s`.
- un vocal ambigu passe mieux: `club/col` devient `Claude / call`.
- la cle reste dans `~/.config/king-kusaila/openai.env`, permissions `600`, jamais dans les scripts.

#### Phase 6: premier gros patch King

Premier patch important vu dans la session:

- ajoute `.local/bin/voice-transcribe`
- ajoute `.local/bin/voice-dictate-toggle`
- ajoute `.local/bin/king-kusaila-toggle`
- ajoute `.king-kusaila/KING_KUSAILA.md`
- ajoute `.king-kusaila/skills/voice-dictation.md`
- ajoute `.king-kusaila/skills/claude-mission-runner.md`
- ajoute `.king-kusaila/jobs/README.md`

Puis:

- `chmod +x` sur les scripts.
- bind Hyprland dans `~/.config/hypr/userprefs.conf`.

Bind initial ajoute:

```ini
unbind = SUPER, C
unbind = SUPER, V
bind = SUPER, C, exec, ~/.local/bin/voice-dictate-toggle
bind = SUPER, V, exec, ~/.local/bin/king-kusaila-toggle
```

Ensuite corrige en chemins absolus:

```ini
bind = SUPER, C, exec, /home/kusaila/.local/bin/voice-dictate-toggle
bind = SUPER, V, exec, /home/kusaila/.local/bin/king-kusaila-toggle
```

Raison: Hyprland/hotkeys ne doivent pas dependre de `~` ou du shell courant.

#### Phase 7: naly recadre King: pas juste un script, un OS IA visible

naly precise que King doit ouvrir Claude Code et "faire tout", ou travailler cache:

- visible si besoin: terminal Claude Code.
- background si demande cache/background.
- pas juste une notif.
- pas une app random.
- un Jarvis local.

Le script `king-kusaila-toggle` evolue:

- cree un dossier de job durable dans `~/.king-kusaila/jobs/<timestamp>-<slug>/`.
- ecrit `mission.txt`.
- ecrit `system.md`.
- ecrit `prompt.md`.
- ecrit `STATUS.md`.
- ecrit `mode.txt`.
- cree `run-interactive.sh`.
- cree `run-background.sh`.

Mode interactif:

- ouvre `kitty`.
- titre: `King Kusaila - <slug>`.
- lance `claude`.
- force bypass permissions:

```bash
claude --dangerously-skip-permissions --permission-mode bypassPermissions
```

Mode background:

- lance `claude --print`.
- redirige sortie vers `claude.log`.
- note exit code / statut.
- avertit seulement fin ou erreur.

#### Phase 8: modes background / Claude Code visible

Au depart, la logique teste des mots dans la mission:

- background/en fond/cache/silent -> background.
- terminal/visible/ouvre Claude Code/interactif -> interactive.

Puis naly veut pouvoir choisir si la phrase ne dit pas clairement.

Plusieurs iterations:

1. `rofi`/`zenity` basique.
2. Chooser GTK custom `king-kusaila-choice`.
3. Chooser asynchrone qui s'ouvre pendant la transcription.

Decision finale:

- Si la transcription dit clairement `background` ou `Claude Code`, la voix gagne.
- Sinon le choix UI est utilise.
- Le choix doit apparaitre juste apres le 2e `Super+V`, meme si GPT n'a pas fini de transcrire.
- Pas de trou visuel entre l'avatar et le choix.

Fonctions finales dans `king-kusaila-toggle`:

- `infer_mode`
- `choose_mode`
- `start_choice_async`
- `stop_choice_async`
- `finish_choice_async`

#### Phase 9: assets King retrouves et convertis

naly met des assets dans Downloads. La session trouve notamment:

- `KING KUSAILA.png`
- `king kusaila talking.mp4`
- `king kusaila dancing.mp4`
- `king kusaila celebrating.mp4`
- `king kusaila sulking.mp4`
- `king kusaila twerking.mp4`
- un asset/clip `king kusaila choice`

La session extrait/prepare des frames PNG:

```text
~/.king-kusaila/assets/frames/talking/
~/.king-kusaila/assets/frames/dancing/
~/.king-kusaila/assets/frames/celebrating/
~/.king-kusaila/assets/frames/sulking/
~/.king-kusaila/assets/frames/choice/
```

Etat observe pendant relais:

- `97` PNG pour `talking`.
- `97` PNG pour `dancing`.
- `97` PNG pour `celebrating`.
- `97` PNG pour `sulking`.
- `97` PNG pour `choice`.

Correspondances mentales:

- `listen` / `recording` -> talking/dancing selon version.
- `think` / transcription -> talking/processing.
- `launch` / mission -> dancing.
- `done` -> celebrating.
- `error` -> sulking.
- `choice` -> animation speciale choix.

#### Phase 10: overlay visuel, du bricolage mpv au daemon GTK

Premiere approche:

- `mpv` en fenetre `King Kusaila Visual`.
- Hyprland windowrules pour float/pin/opacity.
- tentative de `nofocus`.
- probleme: pas assez overlay, focus/fenetres bizarres, background visible, placement pas ideal.

naly critique:

```text
ca ouvre le micro mais pas du tout king kusaila qui apparait
echap ferme fenetre
micro plus visible
```

Puis apres test direct:

```text
ok ca rend super bien mais dream = pas de background
flotter
opacite reduite
animation specifique
fait toi kiffer
```

Ensuite:

```text
pas de background stp
plus petit
```

La session inspecte les frames avec `ffmpeg` / ImageMagick, puis passe a GTK.

Premier script GTK:

- `king-kusaila-overlay`

Bug trouve:

```text
ImportError: Requiring namespace 'Gdk' version '3.0', but '4.0' is already loaded
```

Fix:

```python
gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
```

Ensuite `gtk-layer-shell` est detecte:

```text
gtk-layer-shell: yes
```

Donc l'overlay devient une vraie layer shell, pas une fenetre normale a combattre avec Hyprland.

#### Phase 11: daemon `king-kusaila-visuald`

Pour supprimer le delai de spawn GTK/Python, la session cree un daemon chaud:

- `/home/kusaila/.local/bin/king-kusaila-visuald`
- `/home/kusaila/.local/bin/king-kusaila-visual`

Le daemon:

- ecoute un socket runtime:

```text
${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/visuald.sock
```

- garde un PID file:

```text
${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/visuald.pid
```

- preload les premiers frames.
- affiche/cache sans relancer GTK.
- utilise `GtkLayerShell.Layer.OVERLAY`.
- se place maintenant au centre du moniteur focus.
- taille finale actuelle: environ `280x376`.

Probleme detecte:

- le daemon quittait parfois apres `hide`.
- le socket restait stale.
- le prochain `Super+V` repayait un spawn lent.

Fix final:

- ne plus faire `win.hide()`.
- garder une fenetre mappee `1x1` transparente.
- vider les frames quand cache.
- stopper le timer d'animation en hide.
- utiliser `setsid -f` dans le wrapper pour detacher le daemon de la session shell.

Preuves finales dans la session:

- appel wrapper mesure a `13 ms`.
- daemon visible apres `setsid -f`.
- CPU cache mesure autour de `0.9%` apres tests/preload.
- RSS autour de `72M`.

Conclusion de la session:

```text
King visual est en daemon detache avec setsid
Super+V n'a plus besoin de spawn GTK/Python
appel mesure a 13 ms
daemon ne se ferme plus au hide
1x1 transparent
```

#### Phase 12: chooser visuel et critique "delai"

naly envoie une critique avec screenshot:

```text
tas completement casse le truc + ya tjrs du delai
choix apparaisse JUSTE apres meme si gpt na pas fini de transcribe encore
smooth
```

La bonne decision UX qui sort de cette critique:

- Le choix doit s'ouvrir immediatement apres l'arret micro.
- La transcription GPT tourne en parallele.
- Si la transcription force un mode, le choix se ferme automatiquement.
- Sinon le choix utilisateur est pris.
- Il ne faut pas masquer King trop tot et creer un blanc.

Patch cle:

- Ajout de `CHOICE_OUT`.
- Ajout de `CHOICE_LAUNCH_PID`.
- `start_choice_async` lance `king-kusaila-choice`.
- `finish_choice_async` attend/lit la sortie.
- `stop_choice_async` tue le choix si la voix gagne.

#### Phase 13: Hyprland final

Dans `~/.config/hypr/userprefs.conf`, la session finit avec:

```ini
# King Kusaila voice layer
# Super+C = dictee locale Whisper -> colle dans la fenetre active + journalise
# Super+V = mission vocale -> demande background/terminal puis lance King Kusaila
unbind = SUPER, C
unbind = SUPER, V
bind = SUPER, C, exec, /home/kusaila/.local/bin/voice-dictate-toggle
bind = SUPER, V, exec, /home/kusaila/.local/bin/king-kusaila-toggle
exec-once = /home/kusaila/.local/bin/king-kusaila-visual --daemon-start
```

Et des rules pour les fenetres/layers quand necessaire:

- `King Kusaila Visual`
- `King Kusaila Choice`
- float
- pin
- no decoration
- border size 0
- rounding 0
- opacity adaptee
- no blur

Le point critique:

- `exec-once` garde le daemon chaud.
- Si on le retire, King risque de redevenir lent au premier `Super+V`.

#### Phase 14: validation utilisateur finale

Dernier retour utilisateur dans la session Codex:

```text
ok c MASTERCLASS nickel place juste kusaila au milieu quand jappuie sur super + v et sinon c EXCELLENT
```

Donc l'etat final attendu apres cette session:

- le systeme marche;
- l'UX est acceptee;
- seule demande finale: centrer Kusaila quand `Super+V` est appuye.

Ce dernier point a ete pris en compte dans l'etat courant du daemon: `king-kusaila-visuald` centre l'avatar sur le moniteur focus.

### Decisions de session a ne pas perdre

1. King Kusaila n'est pas une app de chat.

Il est l'operateur local du PC. Il recoit une mission vocale, lance Claude Code, continue, log, et revient.

2. Claude Code est le moteur principal.

Ne pas partir sur Harness/Hermes/OpenClaw/API-runner sauf demande explicite. La preference de naly est plan-first: utiliser les credits/abonnement Claude Code autant que possible.

3. `Super+C` et `Super+V` sont deux gestes differents.

- `Super+C` = dictee partout.
- `Super+V` = mission King.

Ne pas les fusionner.

4. `Super+V` est un toggle.

- appui 1: enregistre.
- appui 2: stoppe et lance la suite.

Pas de hold-to-talk pour l'etat actuel.

5. La qualite ASR attendue est OpenAI-level.

Local whisper.cpp existe en fallback, mais le backend par defaut est OpenAI si la cle est la.

6. Le choix de mode doit etre immediat.

Le chooser ne doit pas attendre la fin GPT si la phrase ne force pas deja un mode.

7. La voix gagne sur l'UI.

Si la transcription contient clairement `background`, `en fond`, `cache`, `Claude Code`, `terminal`, etc., elle override le chooser.

8. L'avatar doit etre instantane.

Daemon chaud obligatoire. Eviter tout changement qui relance Python/GTK a chaque hotkey.

9. Background veut dire vraiment background.

Pas de terminal visible, logs dans le job, statut Waybar/visual, notification seulement fin/erreur.

10. Interactif veut dire Claude Code visible.

Ouvrir `kitty`, bypass permissions, dans un dossier projet stable, avec prompt system King.

11. Les projets interactifs vont dans `~/future/saas`.

Le script courant cree un dossier dans `~/future/saas/<project_slug>` pour ne pas lancer Claude dans un coin random.

12. Les jobs sont durables.

Ne pas faire juste `claude -p "..."` sans dossier de job, car naly doit pouvoir reprendre/inspecter.

13. Pas de prompt bloquant "I trust this folder".

Le script patch `.claude.json`/settings pour bypass/trust.

14. Pas de notifications systeme moches comme UX principale.

Waybar + avatar + choix custom d'abord.

15. Ne pas detruire le rendu transparent.

L'ancien clear Cairo avait casse le design du choix. Attention avant de toucher a `king-kusaila-choice`.

### Patches majeurs vus dans la session Codex

Liste utile pour rechercher dans le JSONL:

- `L820`: creation initiale des scripts et docs King.
- `L829`: naly recadre King comme IA du PC qui ouvre Claude Code / bosse cache.
- autour `L1076`: ajout des binds Hyprland `Super+C` / `Super+V`.
- autour `L1514`: decision ASR locale rapide `base` vs `small` et journal King.
- autour `L1595`: remplacement des notifs par statut King/Waybar/visual.
- autour `L1949`: inventaire des assets King dans Downloads.
- autour `L2105`: integration overlay dans `Super+V`.
- autour `L2315`: bascule OpenAI `gpt-4o-transcribe` + fallback local.
- autour `L2375`: clarification background par defaut / mode visible.
- autour `L2465`: ajout du choix de mode.
- autour `L5108`: choix lance pendant transcription.
- autour `L5120`: patch `start_choice_async` / `finish_choice_async`.
- autour `L5201`: bug daemon qui quitte apres hide.
- autour `L5279`: hide en `1x1` transparent.
- autour `L5318`: `setsid -f` pour detacher le daemon.
- autour `L5354`: validation finale technique.
- autour `L5360`: validation naly "MASTERCLASS" + demande centrage.

### Ce que les sessions Claude ajoutent au contexte

Les deux sessions Claude ne sont pas la source principale de King, mais elles expliquent la machine autour.

#### Claude session `8b68af96...`

Cette session contient:

- rappel des commandes Claude:

```bash
claude --continue
claude -c
claude --resume
claude -r
claude --resume <session-id>
```

- recherche des anciennes sessions Claude dans `~/.claude/projects`.
- identification d'une grosse session de migration:

```text
1d49d65c-87ee-4915-8bcd-06a6b8518c8c
```

Cette ancienne session parlait de:

- arrivee sur CachyOS;
- installation HyDE;
- virer Ghostty/oh-my-zsh;
- jobs/lws;
- services systemd utilisateur;
- ProtonDrive/rclone;
- avatar timeline auto-update;
- memoire de migration;
- creation de `/home/kusaila/RACCOURCIS-HYPRLAND.md`.

Points utiles pour King:

- la machine est deja organisee autour de HyDE/Hyprland;
- `SUPER+V` et `SUPER+C` etaient avant des raccourcis HyDE standards, donc King les a volontairement remappes;
- Claude Code est deja l'outil central dans le workflow;
- un launcher `Super+Space` existe:

```ini
bind = SUPER, space, exec, kitty --title "Claude Launcher" -e ~/.local/bin/claude-here.sh
```

- `systemctl --user`, linger, services, rclone, etc. font partie du contexte machine.

#### Claude session `b1eea509...`

Cette session est plus proche de l'etat Hyprland final. Elle contient:

- travail sur wallpaper anime multi-ecran;
- optimisation pause/evenementielle;
- correction du launcher Claude `SUPER+Space`;
- ajout d'un compacteur de workspaces manuel:

```text
/home/kusaila/.local/bin/hypr-compact-ws.sh
```

- ajout bind:

```ini
bindd = SUPER Control, R, [Workspaces] compacter les numéros, exec, ~/.local/bin/hypr-compact-ws.sh
```

- backups file-history de:
  - `.local/bin/anim-wallpaper-smart.sh`
  - `.local/bin/anim-wallpaper-listener.py`
  - `.local/bin/claude-here.sh`
  - `.local/bin/hypr-compact-ws.sh`
  - `.config/hypr/userprefs.conf`

Points utiles pour King:

- `userprefs.conf` est un fichier actif et modifie souvent.
- Il ne faut pas ecraser les binds ajoutes apres King.
- Le workflow Hyprland de naly evolue vite; verifier le fichier courant avant patch.
- Les workspaces et multi-ecrans comptent: l'overlay King doit se placer sur le moniteur focus, pas en dur sur un ecran.

### Extraction rapide si un agent veut re-scruter

Pour refaire une timeline Codex propre:

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path('/home/kusaila/.codex/sessions/2026/06/26/rollout-2026-06-26T06-29-27-019f0230-9aa3-7123-b595-6e036295d994.jsonl')
keys = ['king','kusaila','Super+V','Super+C','whisper','voice','transcribe','hypr','overlay','visuald','choice','Claude Code','dangerously']
for i, line in enumerate(p.open(), 1):
    try:
        d = json.loads(line)
    except Exception:
        continue
    s = json.dumps(d, ensure_ascii=False)
    if any(k.lower() in s.lower() for k in keys):
        print(f'--- L{i} ---')
        print(s[:1200].replace('\\n',' ')[:1200])
PY
```

Pour grepper directement:

```bash
rg -n "king|kusaila|Super\\+V|Super\\+C|whisper|transcribe|visuald|choice|dangerously|bypassPermissions|gpt-4o-transcribe|setsid|MASTERCLASS" \
  /home/kusaila/.codex/sessions/2026/06/26/rollout-2026-06-26T06-29-27-019f0230-9aa3-7123-b595-6e036295d994.jsonl
```

Pour verifier les sessions Claude:

```bash
rg -n "king|kusaila|userprefs|Super|hypr|claude --continue|claude --resume|bypassPermissions|file-history|wallpaper|workspace" \
  /home/kusaila/.claude/projects/-home-kusaila/8b68af96-8957-485f-96fb-28e9e4fb10fa.jsonl \
  /home/kusaila/.claude/projects/-home-kusaila/b1eea509-4133-433a-ba8d-85c667509fbf.jsonl
```

## Intention produit

King Kusaila n'est pas juste une dictee. L'idee est:

1. Appuyer sur `Super+V`.
2. Voir King Kusaila apparaitre tout de suite, en vrai overlay, pas une notif moche.
3. Parler une mission naturelle.
4. Re-appuyer sur `Super+V` pour stopper.
5. Transcription automatique.
6. Si la phrase contient `background`, `en fond`, `caché`, etc. -> lancer en background.
7. Si la phrase contient `Claude Code`, `terminal`, `interactif`, etc. -> ouvrir une session Claude Code visible.
8. Sinon afficher un choix stylise `background` vs `Claude Code`.
9. Claude travaille avec autonomie maximale, bypass permissions, et n'interrompt l'utilisateur qu'une fois fini ou vraiment bloque.
10. A la fin, King revient avec animation `done` ou `error`, Waybar change d'etat, et les logs restent dans le dossier de job.

Vibe voulue:

- Un vrai operateur local, style "Jarvis", mais adapte a Hyprland.
- Pas de confirmations inutiles.
- Pas de questions "I trust this folder".
- Pas de "no exit" / prompt bloquant.
- Les agents doivent se debrouiller, lire les erreurs, relancer, contourner, verifier.
- Le relais doit comprendre que naly prefere les agents qui FONT.

## Chronologie des grosses etapes

### 1. Premiere idee: dictee vocale `Super+C`

Objectif initial: parler au PC et faire entrer le texte dans la fenetre active.

Ce qui a ete mis en place:

- Script principal: `/home/kusaila/.local/bin/voice-dictate-toggle`
- Premier appui: lance l'enregistrement audio dans le runtime dir.
- Deuxieme appui: stoppe l'enregistrement, transcrit, copie, tape le texte.
- Journalisation des notes dans `~/.king-kusaila/voice-notes/YYYY-MM-DD.md`.
- Etat Waybar via `king-voice-status`.

Flux:

```text
Super+C
  -> voice-dictate-toggle
  -> pw-record input.wav
Super+C again
  -> kill -INT pw-record
  -> voice-transcribe input.wav
  -> wl-copy
  -> wtype dans la fenetre active
  -> append dans ~/.king-kusaila/voice-notes/YYYY-MM-DD.md
```

Details importants:

- `KING_RECORD_SOURCE` peut forcer une source micro.
- Sinon le script choisit le premier `alsa_input.*` non monitor via `pactl list sources short`.
- `sony-audio-fix` est appele avant/apres pour retablir le profil audio Bluetooth hi-fi.
- Si un choix King Kusaila est ouvert, `Super+C` sert aussi a fermer ce choix proprement.

### 2. Transcription: OpenAI rapide + fallback local

Scripts:

```text
/home/kusaila/.local/bin/voice-transcribe
/home/kusaila/.local/bin/voice-transcribe-openai
/home/kusaila/.local/bin/voice-transcribe-local
```

Backend par defaut:

- `voice-transcribe` lit `~/.config/king-kusaila/openai.env`.
- Si `OPENAI_API_KEY` existe, il appelle `voice-transcribe-openai`.
- Mode OpenAI par defaut: `gpt-4o-transcribe`.
- Si OpenAI echoue ou renvoie vide, fallback vers whisper.cpp local.

Variables utiles:

```bash
KING_TRANSCRIBE_BACKEND=local        # force local
KING_OPENAI_TRANSCRIBE_MODEL=...     # par defaut gpt-4o-transcribe
KING_OPENAI_TRANSCRIBE_PROMPT=...    # vocab technique FR/EN
KING_WHISPER_MODEL=...               # par defaut ggml-base.bin
KING_WHISPER_THREADS=8
```

Local:

```text
~/.local/bin/voice-transcribe-local
```

Utilise:

```bash
whisper-cli \
  --model "$MODEL" \
  --file "$audio" \
  --language auto \
  --no-timestamps \
  --output-txt \
  --output-file "$base" \
  --threads "${KING_WHISPER_THREADS:-8}"
```

Notes de benchmark gardees dans `~/.king-kusaila/LOG.md`:

- `ggml-base.bin`: suffisamment rapide pour dictee hotkey, environ 4.4s pour 14.6s audio.
- `ggml-small.bin`: meilleure qualite sur certains mots, mais plus lent.
- `ggml-large-v3-turbo.bin`: disponible mais trop lent pour hotkey directe.
- OpenAI `gpt-4o-transcribe`: beaucoup plus propre FR/EN tech, environ 1.3s a 3.0s pour des clips 13s-29s.

Important securite:

- Ne jamais mettre la cle OpenAI dans ce `.md`.
- Le fichier env existe cote machine, normalement permissions `0600`.

### 3. Deuxieme idee: mission vocale `Super+V`

Script principal:

```text
/home/kusaila/.local/bin/king-kusaila-toggle
```

Fonction:

- Premier appui: record mission audio + affiche King Kusaila en mode `listen`.
- Deuxieme appui: stop record, transcrit, cree un job, determine le mode, lance Claude.

Runtime:

```text
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/king-kusaila-command"
ROOT="$HOME/.king-kusaila"
JOBS_DIR="$ROOT/jobs"
SAAS_DIR="$HOME/future/saas"
```

Fichiers runtime:

```text
$STATE_DIR/record.pid
$STATE_DIR/mission.wav
$STATE_DIR/choice.out
$STATE_DIR/choice-launch.pid
$STATE_DIR/choice.debug
$STATE_DIR/choice.err
$STATE_DIR/choice.pid
```

### 4. Detection du mode background/interactif

Dans `king-kusaila-toggle`, fonction `infer_mode`.

Mode background si la mission contient un signal clair:

```text
background
bg
arriere-plan
arrière-plan
tache de fond
tâche de fond
en fond
mode fond
cache
caché
cacher
hidden
silently
```

Mode interactif si la mission contient:

```text
claude code
claude-code
code claude
terminal
interactif
interactive
```

Si les deux sont presents ou aucun n'est clair:

```text
ask
```

Puis on affiche le chooser King Kusaila.

### 5. Choix stylise background / Claude Code

Script:

```text
/home/kusaila/.local/bin/king-kusaila-choice
```

Role:

- Fenetre GTK transparente titre `King Kusaila Choice`.
- Taille actuelle: `330x443`.
- Lit les frames dans `~/.king-kusaila/assets/frames/choice`.
- Affiche une animation de choix.
- Zone gauche = background.
- Zone droite = interactive.
- Hover colore legerement la zone selectionnee.
- Clavier:
  - `Esc` -> cancel
  - fleches gauche/haut ou `h/k` -> background
  - fleches droite/bas ou `l/j` -> interactive
  - `b` -> background
  - `c` ou `i` -> interactive
  - `Enter` / `Space` -> valide la selection

Comportement important:

- Au lancement du choix, il appelle `king-kusaila-visual hide` pour cacher l'avatar principal.
- Si la transcription dit clairement background/interactif, le choix est ferme automatiquement et la voix gagne.
- Sinon le choix utilisateur est utilise.

Fallbacks dans `king-kusaila-toggle`:

1. `king-kusaila-choice`
2. `rofi` avec theme `~/.config/rofi/king-kusaila-mode.rasi`
3. `zenity`
4. cancel

### 6. Overlay anime King Kusaila

Scripts:

```text
/home/kusaila/.local/bin/king-kusaila-visual
/home/kusaila/.local/bin/king-kusaila-visuald
/home/kusaila/.local/bin/king-kusaila-send
```

`king-kusaila-visual`:

- Wrapper bash.
- Demarre le daemon si besoin.
- Envoie une commande UNIX datagram socket au daemon via `king-kusaila-send`.
- Mode special:

```bash
king-kusaila-visual --daemon-start
```

sert au `exec-once` Hyprland pour garder le daemon chaud au demarrage.

`king-kusaila-send`:

- Binaire compile.
- Role: envoyer `COMMAND` au socket UNIX du daemon.
- Usage apparent:

```bash
king-kusaila-send SOCKET COMMAND
```

Ne pas le lire avec `cat`/`sed`, c'est un ELF.

`king-kusaila-visuald`:

- Python GTK3 + GtkLayerShell.
- Socket:

```text
${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/visuald.sock
```

- PID:

```text
${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/visuald.pid
```

- Titre de fenetre:

```text
King Kusaila Visual
```

- Namespace layer shell:

```text
king-kusaila
```

Modes -> animations:

```text
listen / record / talk / speaking       -> frames/talking
think / transcribe / processing/working -> frames/dancing
done / success / launch / king          -> frames/celebrating
error / failed / blocked                -> frames/sulking
```

Position/taille actuelle:

```text
position = center
width = 280
height = 376
done/error/launch = visible 4.5s puis hide
listen/think = visible jusqu'a hide/stop
opacity = 0.92
tick animation = 42 ms
```

Optimisation importante faite:

- Au debut, l'overlay spawnait lentement et King n'apparaissait pas tout de suite.
- On a transforme `king-kusaila-visuald` en daemon detache.
- `king-kusaila-visual --daemon-start` garde GTK chaud.
- `hide` ne tue plus la fenetre: il la rend quasi invisible en `1x1` avec pixbuf transparent.
- Le prochain `listen` est donc quasi instantane.
- Test mesure dans la conversation: appel `king-kusaila-visual listen` autour de `13 ms`.
- CPU daemon apres test/preload autour de `0.9%`, puis devrait descendre en idle.

Bug corrige:

- Un clear Cairo avait casse le rendu du choix. On a rollback/ajuste pour garder le rendu transparent sans detruire l'image.

### 7. Assets

Racine:

```text
/home/kusaila/.king-kusaila/assets
```

Videos transparentes sources:

```text
/home/kusaila/.king-kusaila/assets/transparent/king-talking.webm
/home/kusaila/.king-kusaila/assets/transparent/king-dancing.webm
/home/kusaila/.king-kusaila/assets/transparent/king-celebrating.webm
/home/kusaila/.king-kusaila/assets/transparent/king-sulking.webm
```

Frames PNG:

```text
/home/kusaila/.king-kusaila/assets/frames/talking
/home/kusaila/.king-kusaila/assets/frames/dancing
/home/kusaila/.king-kusaila/assets/frames/celebrating
/home/kusaila/.king-kusaila/assets/frames/sulking
/home/kusaila/.king-kusaila/assets/frames/choice
```

Comptage actuel:

```text
talking     97 PNG
dancing     97 PNG
celebrating 97 PNG
sulking     97 PNG
choice      97 PNG
```

Origine mentionnee dans la conversation:

- L'utilisateur avait mis des assets dans Downloads: image/animations King Kusaila, dont `king kusaila.mp4`.
- Ces assets ont ete transformes en frames pour GTK.

### 8. Jobs King Kusaila

Racine:

```text
/home/kusaila/.king-kusaila/jobs
```

Chaque mission vocale cree un dossier:

```text
YYYYMMDD-HHMMSS-slug-de-la-mission
```

Fichiers typiques:

```text
mission.txt          # transcription brute de la mission
system.md            # prompt system King Kusaila
prompt.md            # prompt passe a Claude
mode.txt             # background / interactive / cancel
STATUS.md            # etat courant
run-interactive.sh   # lance Claude Code visible
open-cli.sh          # ouvre kitty/workspace puis run-interactive
run-background.sh    # lance Claude --print en fond
kitty.log            # log ouverture CLI si interactif
claude.log           # log Claude si background
FINAL.md             # attendu a la fin par le system prompt
```

Exemples de jobs existants:

```text
20260626-200625-on-va-commencer-par-configurer-l-diteur-de-texte
20260627-020245-ok-on-va-faire-une-application-pour-gagner-des-e
20260627-022217-on-va-essayer-de-cr-er-une-application-pour-les-
20260627-031620-faisons-une-appli-pour-le-dernier-youtube
20260627-034442-est-ce-que-tu-peux-cr-er-une-application-de-chie
20260627-054143-pour-jouer-au-poker
```

Log global:

```text
/home/kusaila/.king-kusaila/LOG.md
```

### 9. Prompt system King Kusaila

Le prompt genere dans chaque job dit en substance:

```text
You are King Kusaila, the local AI operator for this CachyOS/Hyprland laptop.

Work like a serious autonomous engineering agent:
- Continue until the requested task is genuinely complete or clearly blocked.
- Prefer concrete changes and verifiable outputs over commentary.
- Use the local filesystem and shell when needed.
- Keep a concise audit trail in the job folder.
- MAXIMUM AUTONOMY: solve your own problems before escalating to the human.
  Read the full error, read docs/source, try another approach, work around it,
  debug in a loop (act -> verify -> fix).
- Asking the user a question is a small failure to avoid.
- Only stop to ask if genuinely BLOCKED, destructive/irreversible, or truly ambiguous.
- When finished, write FINAL.md with what changed, where, and risk.
- In background mode, do the work without waiting for more user chat unless impossible.
```

C'est important: ce prompt reprend la preference forte de naly "agents autonomes, pas assistants bavards".

### 10. Mode interactif

Si le mode est `interactive`:

1. `king-kusaila-toggle` cree un projet sous:

```text
/home/kusaila/future/saas/<slug>
```

2. Le slug est genere depuis le premier mot utile de la mission, apres filtre de stopwords.

Probleme connu:

- Ce slug est parfois trop nul/generique:
  - `Ok, on va faire...` -> `/home/kusaila/future/saas/ok`
  - `On va essayer...` -> `/home/kusaila/future/saas/on`
  - `Faisons...` -> `/home/kusaila/future/saas/faisons`
  - `pour jouer au poker` -> `/home/kusaila/future/saas/jouer`

A ameliorer: utiliser un mini summarizer local/LLM ou heuristique meilleure pour trouver un vrai nom projet.

3. Il cree:

```text
<project_dir>/.claude/settings.local.json
```

avec:

```json
{
  "includeCoAuthoredBy": false,
  "permissions": {
    "defaultMode": "bypassPermissions",
    "additionalDirectories": [
      "/home/kusaila",
      "/home/kusaila/future"
    ],
    "allow": [
      "Bash(*)",
      "Edit(*)",
      "Read(*)",
      "Write(*)",
      "MultiEdit(*)",
      "WebFetch",
      "WebSearch"
    ]
  },
  "skipDangerousModePermissionPrompt": true,
  "skipWorkflowUsageWarning": true
}
```

4. Il modifie `~/.claude.json` via `jq` pour mettre:

```json
hasTrustDialogAccepted: true
```

sur le dossier projet, afin d'eviter le prompt de confiance.

5. Il ouvre une fenetre `kitty --hold` avec titre:

```text
King Kusaila - <slug>
```

6. Commande Claude generee:

```bash
claude \
  --dangerously-skip-permissions \
  --permission-mode bypassPermissions \
  --settings "$project_dir/.claude/settings.local.json" \
  --add-dir "$HOME" \
  --add-dir "$HOME/future" \
  --name "King Kusaila - $slug" \
  --append-system-prompt "$(cat "$job/system.md")" \
  "$(cat "$job/prompt.md")"
```

7. Si Claude finit code 0:

```text
king-voice-status done "CLAUDE CODE FINISHED"
king-kusaila-visual done
```

8. Sinon:

```text
king-voice-status error "CLAUDE CODE CLOSED"
king-kusaila-visual error
```

### 11. Mode background

Si le mode est `background`:

- Pas de nouveau projet.
- `project_dir=$HOME`.
- Lance Claude en `--print`.
- Ecrit tout dans:

```text
$job/claude.log
```

Commande generee:

```bash
claude \
  --print \
  --dangerously-skip-permissions \
  --permission-mode bypassPermissions \
  --add-dir "$HOME" \
  --name "King Kusaila - $slug" \
  --append-system-prompt "$(cat "$job/system.md")" \
  "$(cat "$job/prompt.md")" \
  > "$job/claude.log" 2>&1
```

Fin:

- Met a jour `STATUS.md`.
- Met a jour `LOG.md`.
- Notifie avec `notify-send`.
- Affiche `done` ou `error`.

### 12. Integration Hyprland

Fichier:

```text
/home/kusaila/.config/hypr/userprefs.conf
```

Bloc actuel:

```ini
# King Kusaila voice layer
# Super+C = dictee locale Whisper -> colle dans la fenetre active + journalise
# Super+V = mission vocale -> demande background/terminal puis lance King Kusaila
unbind = SUPER, C
unbind = SUPER, V
bind = SUPER, C, exec, /home/kusaila/.local/bin/voice-dictate-toggle
bind = SUPER, V, exec, /home/kusaila/.local/bin/king-kusaila-toggle
exec-once = /home/kusaila/.local/bin/king-kusaila-visual --daemon-start
windowrule = float true, match:title ^(King Kusaila Visual)$
windowrule = pin true, match:title ^(King Kusaila Visual)$
windowrule = decorate false, match:title ^(King Kusaila Visual)$
windowrule = border_size 0, match:title ^(King Kusaila Visual)$
windowrule = rounding 0, match:title ^(King Kusaila Visual)$
windowrule = opacity 0.92 0.92, match:title ^(King Kusaila Visual)$
windowrule = no_blur true, match:title ^(King Kusaila Visual)$
windowrule = float true, match:title ^(King Kusaila Choice)$
windowrule = pin true, match:title ^(King Kusaila Choice)$
windowrule = decorate false, match:title ^(King Kusaila Choice)$
windowrule = border_size 0, match:title ^(King Kusaila Choice)$
windowrule = rounding 0, match:title ^(King Kusaila Choice)$
windowrule = opacity 1.0 1.0, match:title ^(King Kusaila Choice)$
windowrule = no_blur true, match:title ^(King Kusaila Choice)$
```

Autres bind utiles ajoutes autour:

```ini
bind = SUPER, space, exec, kitty --title "Claude Launcher" -e ~/.local/bin/claude-here.sh
bind = , Print, exec, grimblast copy area
bindd = SUPER Control, R, [Workspaces] compacter les numéros, exec, ~/.local/bin/hypr-compact-ws.sh
```

Important:

- `Super+V` etait auparavant utilise par HyDE pour l'historique presse-papier, il a ete unbind/rebind.
- `Super+C` etait probablement un raccourci editeur dans la conf, il a ete repris pour la dictee.

### 13. Waybar / etat vocal

Script d'etat:

```text
/home/kusaila/.local/bin/king-voice-status
```

Il ecrit:

```text
${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/voice-status
```

Format:

```text
state|label|timestamp
```

States autorises:

```text
idle
recording
transcribing
done
error
king
```

Puis:

```bash
pkill -RTMIN+8 waybar
```

pour rafraichir Waybar.

Script de rendu Waybar:

```text
/home/kusaila/.local/bin/waybar-king-voice.sh
```

Il est reference dans les recherches mais il faut verifier s'il est bien branche dans le layout Waybar actif. Le layout lu:

```text
/home/kusaila/.local/share/waybar/layouts/naly-top.jsonc
```

contient deja `custom/claude`, pas forcement `custom/king-voice` dans l'extrait verifie. A verifier si l'indicateur vocal n'apparait pas.

Autre widget existant:

```text
/home/kusaila/.local/bin/waybar-claude.sh
```

Role:

- Affiche usage Claude plan / ccusage.
- Clique ouvre `claude-here.sh`.

### 14. Fichiers importants a connaitre

#### Scripts King

```text
/home/kusaila/.local/bin/king-kusaila-toggle
/home/kusaila/.local/bin/king-kusaila-visual
/home/kusaila/.local/bin/king-kusaila-visuald
/home/kusaila/.local/bin/king-kusaila-choice
/home/kusaila/.local/bin/king-kusaila-send
/home/kusaila/.local/bin/king-kusaila-demo
/home/kusaila/.local/bin/king-kusaila-overlay
/home/kusaila/.local/bin/king-voice-status
/home/kusaila/.local/bin/waybar-king-voice.sh
```

#### Scripts dictee/transcription

```text
/home/kusaila/.local/bin/voice-dictate-toggle
/home/kusaila/.local/bin/voice-transcribe
/home/kusaila/.local/bin/voice-transcribe-openai
/home/kusaila/.local/bin/voice-transcribe-local
/home/kusaila/.local/bin/voice-transcribe-fw
```

#### Config

```text
/home/kusaila/.config/hypr/userprefs.conf
/home/kusaila/.config/king-kusaila/openai.env
/home/kusaila/.claude.json
/home/kusaila/.codex/AGENTS.md
/home/kusaila/.claude/CLAUDE.md
```

#### Donnees King

```text
/home/kusaila/.king-kusaila/KING_KUSAILA.md
/home/kusaila/.king-kusaila/LOG.md
/home/kusaila/.king-kusaila/jobs/README.md
/home/kusaila/.king-kusaila/jobs/
/home/kusaila/.king-kusaila/voice-notes/
/home/kusaila/.king-kusaila/assets/
```

#### Historiques

```text
/home/kusaila/.codex/history.jsonl
/home/kusaila/.claude/history.jsonl
/home/kusaila/.codex/sessions/2026/06/26/rollout-2026-06-26T06-29-27-019f0230-9aa3-7123-b595-6e036295d994.jsonl
/home/kusaila/.claude/projects/-home-kusaila/8b68af96-8957-485f-96fb-28e9e4fb10fa.jsonl
/home/kusaila/.claude/projects/-home-kusaila/b1eea509-4133-433a-ba8d-85c667509fbf.jsonl
```

### 15. Tests / commandes de verification

Syntaxe bash:

```bash
bash -n \
  /home/kusaila/.local/bin/king-kusaila-toggle \
  /home/kusaila/.local/bin/king-kusaila-visual \
  /home/kusaila/.local/bin/voice-dictate-toggle \
  /home/kusaila/.local/bin/voice-transcribe-local
```

Syntaxe Python:

```bash
python3 -m py_compile \
  /home/kusaila/.local/bin/king-kusaila-visuald \
  /home/kusaila/.local/bin/king-kusaila-choice \
  /home/kusaila/.local/bin/voice-transcribe-openai
```

Demarrer le daemon:

```bash
/home/kusaila/.local/bin/king-kusaila-visual --daemon-start
```

Tester animation:

```bash
/home/kusaila/.local/bin/king-kusaila-visual listen
sleep 1
/home/kusaila/.local/bin/king-kusaila-visual think
sleep 1
/home/kusaila/.local/bin/king-kusaila-visual done
```

Cacher:

```bash
/home/kusaila/.local/bin/king-kusaila-visual hide
```

Verifier daemon:

```bash
ps -eo pid,comm,args | awk '$2 == "python3" && $0 ~ /king-kusaila-visuald/ {print}'
```

Verifier CPU/memoire:

```bash
pid=$(ps -eo pid,comm,args | awk '$2 == "python3" && $0 ~ /king-kusaila-visuald/ {print $1}' | head -1)
ps -p "$pid" -o pid,%cpu,%mem,rss,etime,cmd
```

Tester le choix:

```bash
/home/kusaila/.local/bin/king-kusaila-choice
echo $?
```

Tester transcription OpenAI/local:

```bash
/home/kusaila/.local/bin/voice-transcribe /path/to/audio.wav
KING_TRANSCRIBE_BACKEND=local /home/kusaila/.local/bin/voice-transcribe /path/to/audio.wav
```

Verifier Hyprland:

```bash
hyprctl reload
hyprctl binds | rg 'SUPER.*(C|V)|king-kusaila|voice-dictate'
```

Verifier jobs recents:

```bash
ls -lt /home/kusaila/.king-kusaila/jobs | head
```

Verifier logs d'un job:

```bash
job=/home/kusaila/.king-kusaila/jobs/<job>
cat "$job/mission.txt"
cat "$job/STATUS.md"
tail -120 "$job/claude.log" 2>/dev/null
tail -120 "$job/kitty.log" 2>/dev/null
```

### 16. Bugs / demandes utilisateur deja traitees

#### "Quand j'appuie sur Super+V il doit apparaitre DIRECT"

Resolution:

- Daemon GTK persistant.
- `exec-once = king-kusaila-visual --daemon-start`.
- `hide` conserve une fenetre 1x1 transparente.
- `listen` ne respawn plus Python/GTK.

#### "King Kusaila n'apparait pas quand je parle"

Resolution:

- `notify rec` dans `king-kusaila-toggle` appelle `king-kusaila-visual listen`.
- L'overlay est centre, taille `280x376`.

#### "Le choix background / Claude Code est moche"

Resolution partielle:

- `king-kusaila-choice` utilise une animation `choice` en PNG.
- Zones cliquables gauche/droite.
- Hover discret.
- Fenetre transparente sans decoration.

Reste a ameliorer:

- Le design du choix peut encore etre raffine avec une vraie composition.
- Il faut eviter les textes trop gros ou UI cheap si on refait les assets.

#### "Si je dis background ou Claude Code dans le prompt vocal, ne me redemande pas"

Resolution:

- `infer_mode` parse le texte transcrit.
- Si clair, pas de chooser.
- Si ambigu, chooser.

#### "Pas de question I trust this folder"

Resolution:

- Creation de `.claude/settings.local.json`.
- Patch de `~/.claude.json` avec `hasTrustDialogAccepted: true`.
- Flags Claude:

```text
--dangerously-skip-permissions
--permission-mode bypassPermissions
--settings ...
--add-dir ...
```

#### "Quand c'est Claude Code, cree un nouveau dossier dans future/saas"

Resolution:

- Mode interactif cree `~/future/saas/<slug>`.
- `unique_project_dir` evite d'ecraser un dossier existant en ajoutant `-2`, `-3`, etc.

Limite:

- Slug actuel trop naif.

#### "Apres le choix, je ne veux plus voir King Kusaila; je le revois quand il a fini"

Resolution:

- Le choix cache l'overlay principal.
- `king-kusaila-toggle` appelle `king-kusaila-visual stop` apres choix/mode.
- Fin Claude -> `done` ou `error`.

#### "Echap doit fermer la fenetre de choix"

Resolution:

- `Gdk.KEY_Escape` dans `king-kusaila-choice` -> `finish("cancel")`.

#### "Le micro/etat doit etre visible"

Resolution:

- `king-voice-status` ecrit un etat.
- Le systeme Waybar recoit `RTMIN+8`.
- A verifier: integration exacte du module `waybar-king-voice.sh` dans la config Waybar active.

### 17. Architecture mentale

King Kusaila est compose de 5 couches:

#### Couche A: Hotkeys Hyprland

`userprefs.conf` decide quoi appeler.

```text
Super+C -> voice-dictate-toggle
Super+V -> king-kusaila-toggle
exec-once -> king-kusaila-visual --daemon-start
```

#### Couche B: Capture audio

Les deux toggles utilisent `pw-record`.

```text
record.pid
input.wav / mission.wav
kill -INT pour stopper proprement
```

#### Couche C: ASR

`voice-transcribe` choisit:

```text
OpenAI gpt-4o-transcribe si cle dispo
whisper.cpp local sinon
```

#### Couche D: UX visuelle

```text
king-voice-status -> Waybar
king-kusaila-visuald -> avatar anime overlay
king-kusaila-choice -> choix mode
```

#### Couche E: Execution agent

```text
king-kusaila-toggle -> job folder -> claude command
interactive -> kitty + Claude Code
background -> claude --print + logs
```

### 18. Etat actuel attendu cote utilisateur

#### `Super+C`

1. Appuyer.
2. Waybar devrait indiquer recording.
3. Parler.
4. Re-appuyer.
5. Transcription.
6. Texte tape dans la fenetre active + copie presse-papier.
7. Note ajoutee dans `~/.king-kusaila/voice-notes/`.

#### `Super+V`

1. Appuyer.
2. King apparait au milieu instantanement.
3. Parler mission.
4. Re-appuyer.
5. ASR.
6. Si mode detecte, lancement direct.
7. Sinon choix anime.
8. Si interactive: nouveau workspace/kitty/Claude Code.
9. Si background: pas de fenetre, log dans job.
10. Fin: animation done/error + status.

### 19. Limites / dette technique

#### Slug projet trop faible

Le nom de projet interactif est trop souvent le premier mot non filtre.

Proposition:

- Ajouter une fonction `project_slug_from_mission` plus intelligente:
  - supprimer les verbes faibles au debut (`ok`, `on`, `faisons`, `créer`, `application`, etc.)
  - detecter "pour X" -> prendre X
  - detecter domaine metier (`armuriers`, `poker`, `youtube`) -> prendre ce mot
  - option LLM/plan-first plus tard, mais pas API payante pour un slug si possible.

#### Chooser encore perfectible

Il marche, mais design a polir.

Pistes:

- Refaire une vraie animation `choice` avec zones plus lisibles.
- Integrer labels visuels dans l'asset plutot qu'en GTK texte.
- Garder fond transparent.
- Support multi-monitor plus robuste.

#### Waybar voice status a verifier

`king-voice-status` existe et envoie RTMIN+8.

Il faut confirmer que `waybar-king-voice.sh` est bien branche dans le layout actif. Si non:

- Ajouter `custom/king-voice` dans `modules-right`.
- Configurer `signal: 8`.
- Eviter conflit avec modules existants.

#### Background Claude peut echouer sans UX riche

Le background ecrit `claude.log` et notifie. Mais l'utilisateur ne voit pas toujours le "pourquoi" en cas d'echec.

Piste:

- A la fin `error`, extraire les 15 dernieres lignes de `claude.log` dans `STATUS.md`.
- Eventuellement afficher un court `notify-send` avec raison.

#### Daemon visuel cache en 1x1 transparent

C'est volontaire pour instantaneite. Mais si bug graphique:

```bash
rm -f "${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/visuald.sock" "${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/visuald.pid"
pkill -f king-kusaila-visuald
/home/kusaila/.local/bin/king-kusaila-visual --daemon-start
```

#### Permissions tres larges

Claude est lance avec bypass permissions. C'est voulu pour l'UX "agent qui fait", mais:

- Ne pas dicter de commandes systeme destructives sans intention claire.
- Ideal futur: snapshot Btrfs avant gros changement systeme.
- Ideal futur: guard pour commandes destructives (`rm -rf`, `mkfs`, `dd`, etc.).

#### `king-kusaila-send` est binaire local non documente

Si besoin de le reconstruire:

- Petit programme C qui ouvre socket UNIX datagram et fait `sendto`.
- Alternative possible: remplacer par Python one-liner pour reduire maintenance.

### 20. Roadmap proposee

#### Priorite 1: fiabilite

- Brancher/verifier `waybar-king-voice.sh`.
- Ajouter un mode "status" pour savoir si un job background tourne.
- Ajouter `king-kusaila-status` qui liste:
  - daemon alive?
  - recording?
  - choice open?
  - last job?
  - last error?

#### Priorite 2: meilleur naming projets

- Remplacer le slug naif.
- Eviter dossiers `ok`, `on`, `est`, `faisons`, `jouer`.
- Ecrire un test shell avec phrases exemples.

#### Priorite 3: meilleure reprise Codex/Claude

- Creer un `README_HANDOFF.md` ou garder ce fichier a jour.
- Ajouter une commande:

```bash
king-kusaila-open-last-job
```

qui ouvre le dernier job dans kitty/editor.

#### Priorite 4: TTS

Objectif futur mentionne:

- Quand la mission finit, King peut parler.
- Ne pas le faire maintenant si pas necessaire.
- Preferer une voix locale ou plan-first, pas API token si possible.

#### Priorite 5: screenshots / debug visuel

- Ajouter un mode demo:

```bash
king-kusaila-demo
```

existe deja, mais verifier qu'il montre:
  - recording
  - transcribing
  - choice
  - done
  - error

#### Priorite 6: sauvegarde/dotfiles

King Kusaila, scripts, systemd, Hyprland, skills sont de l'or. Une partie a deja ete discutee avec backup/dotfiles. Il faut s'assurer que:

- `~/.local/bin/king-*`
- `~/.local/bin/voice-*`
- `~/.config/hypr/userprefs.conf`
- `~/.king-kusaila/KING_KUSAILA.md`
- les skills importants

sont versionnes/sauvegardes, mais jamais les secrets:

```text
~/.config/king-kusaila/openai.env
*.env
```

### 21. Commandes utiles pour reprendre vite

Reprendre conversation Codex:

```bash
codex resume 019f0230-9aa3-7123-b595-6e036295d994
```

Chercher toutes references:

```bash
rg -n -i "king kusaila|king-kusaila|Super\\+V|voice-dictate|voice-transcribe" \
  ~/.codex ~/.claude ~/.config ~/.local/bin ~/.king-kusaila
```

Voir scripts:

```bash
sed -n '1,560p' ~/.local/bin/king-kusaila-toggle
sed -n '1,340p' ~/.local/bin/king-kusaila-visuald
sed -n '1,300p' ~/.local/bin/king-kusaila-choice
sed -n '1,220p' ~/.local/bin/voice-dictate-toggle
sed -n '1,220p' ~/.local/bin/voice-transcribe
```

Relancer daemon:

```bash
pkill -f king-kusaila-visuald || true
rm -f "${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/visuald.sock" "${XDG_RUNTIME_DIR:-/tmp}/king-kusaila/visuald.pid"
~/.local/bin/king-kusaila-visual --daemon-start
```

Voir dernier job:

```bash
ls -td ~/.king-kusaila/jobs/* | head -1
```

Ouvrir dernier job:

```bash
job="$(ls -td ~/.king-kusaila/jobs/* | head -1)"
printf '%s\n' "$job"
find "$job" -maxdepth 1 -type f -print
```

Tester ASR avec le dernier audio de mission si encore present:

```bash
ls "${XDG_RUNTIME_DIR:-/tmp}/king-kusaila-command"
~/.local/bin/voice-transcribe "${XDG_RUNTIME_DIR:-/tmp}/king-kusaila-command/mission.wav"
```

### 22. Ce qu'il ne faut pas casser

- Ne pas supprimer `exec-once = king-kusaila-visual --daemon-start`, sinon King redevient lent.
- Ne pas tuer le daemon a chaque hide, sinon l'apparition directe casse.
- Ne pas retirer `--dangerously-skip-permissions` / `--permission-mode bypassPermissions` sans prevenir, car l'objectif est "agent autonome".
- Ne pas committer `~/.config/king-kusaila/openai.env`.
- Ne pas remplacer les assets transparents par un truc non transparent.
- Ne pas remettre un choix rofi basique si le chooser GTK fonctionne.
- Ne pas refaire un prompt King qui pose 15 questions a naly.
- Ne pas oublier que les projets interactifs doivent aller dans `~/future/saas/`.
- Ne pas oublier que la langue de naly est le francais, mais les prompts system peuvent rester anglais pour Claude si utile.

### 23. Etat de preuve

Faits verifies pendant ce relais:

- `~/.local/bin/king-kusaila-toggle` existe et contient la logique mission complete.
- `~/.local/bin/king-kusaila-visuald` existe et centre King en `280x376`.
- `~/.local/bin/king-kusaila-choice` existe et gere clic/clavier/cancel.
- `~/.local/bin/voice-dictate-toggle` existe et gere la dictee.
- `~/.local/bin/voice-transcribe` existe et route OpenAI -> local fallback.
- Hyprland branche `Super+C` et `Super+V`.
- Assets frames: 97 PNG pour chaque etat `talking`, `dancing`, `celebrating`, `sulking`, `choice`.
- Des jobs reels existent dans `~/.king-kusaila/jobs`.
- La session Codex source est `019f0230-9aa3-7123-b595-6e036295d994`.

### 24. Message au prochain agent

Si tu reprends ce chantier:

1. Lis ce fichier.
2. Lis les scripts reels avant de modifier.
3. Verifie le comportement avec commandes locales, pas depuis ta memoire.
4. Garde l'UX instantanee de `Super+V`.
5. Corrige d'abord le slug projet et l'indicateur Waybar si naly demande de continuer.
6. Si naly critique un detail, grave la lecon dans le bon skill/memoire, pas juste dans le chat.
7. Ce projet est un workflow OS personnel, pas un package propre a publier. Priorite: que ca marche sur cette machine.

## 25. Session Claude (2026-06-27) : latence vocale + ecran CLI + qualite Super+C

Agent Claude (Opus). Corrections faites et PROUVEES par mesure, pas par memoire.

### 25.1 Cause racine latence `Super+C` / `Super+V` (le gros morceau)

`sony-audio-fix` (restore profil Bluetooth hi-fi) etait appele EN BLOQUANT dans le
chemin critique, avant `pw-record` au demarrage et avant l'ASR a l'arret. Or il
contient `for _ in {1..15}; do ... sleep 0.2` + `set-card-profile` -> **mesure: 3234 ms**.

Consequences ressenties par naly:
- "ca reconnait trop tard quand je parle" = les ~3 premieres secondes de la phrase
  etaient PERDUES (pw-record demarrait apres le fix BT).
- "quand je stop ca stop pas vraiment" = meme fix BT bloquant + boucle d'attente de
  3 s a l'arret.

Fix (dans `voice-dictate-toggle` ET `king-kusaila-toggle`):
- `start_recording`: lancer `pw-record` D'ABORD, puis `restore_bluetooth_hifi &` en
  async. Le mic est interne (`alsa_input.pci-...`), le fix BT ne touche que la SORTIE,
  donc l'enregistrement n'a pas a l'attendre.
- branche stop: `restore_bluetooth_hifi &` async aussi, et boucle d'attente kill
  raccourcie (`{1..40}` * 0.025 s, casse des que pw-record meurt).

Preuve mesuree:
- demarrage capture reelle: **3234 ms -> 51 ms**.
- mort de `pw-record` sur SIGINT: **2 ms** (la vieille attente de 3 s etait inutile).
- WAV toujours valide apres arret rapide (header + duree OK, transcriptible).

### 25.2 CLI interactif s'ouvrait sur le mauvais ecran

`open-cli.sh` faisait `hyprctl dispatch workspace "name:kusaila-$stamp"` sans cibler
de moniteur -> le workspace nomme atterrissait sur le moniteur focus au moment du
dispatch, qui avait pu changer (overlay/choice). Setup: `eDP-1` (laptop) + `DP-2`.

Fix v1: capturer le moniteur focus AU MOMENT du 2e `Super+V` (avant que
l'overlay/choice ne bouge le focus) via `hyprctl monitors -j | jq ... .focused`,
stocke dans `launch_mon`.

Fix v2 (IMPORTANT, demande naly): NE PLUS creer/basculer sur un workspace nomme.
L'ancien `hyprctl dispatch workspace "name:kusaila-$stamp"` faisait un FLASH "bureau
vide + wallpaper" -> naly ne veut JAMAIS quitter son ecran courant, il veut voir la
fenetre apparaitre devant lui comme `Super+T`. Donc `open-cli.sh` fait seulement
`focusmonitor "$LAUNCH_MON"` (va sur le workspace ACTIF du moniteur, pas un vide)
puis `exec kitty` -> la fenetre s'ouvre sur le workspace courant, sans switch.
Fonction morte `open_new_workspace_for_cli` supprimee.

### 25.3 Qualite `Super+C` niveau Apple : GATE ANTI-HALLUCINATION (crucial)

Preuve du probleme (gpt-4o-transcribe sur audio sans parole):
- silence 1.5 s -> tape "Mais je ne sais pas ou le partager."
- clip 0.2 s (double Super+C accidentel) -> tape "Je suis desole, mais je ne peux
  pas generer de code."

=> a chaque pause/appui accidentel, du FAUX texte etait injecte dans la fenetre active.

Fix central dans `voice-transcribe` (protege `Super+C` ET `Super+V`):
- gate AVANT l'appel ASR: si duree < `KING_MIN_AUDIO_SEC` (0.35 s) OU
  max_volume < `KING_MIN_PEAK_DB` (-40 dB) -> sortie vide, on ne tape rien et on
  n'appelle meme pas l'API (gratuit + instantane).
  Seuils mesures: parole max_volume ~ -0.2 dB ; silence ~ -91 dB (marge enorme).
- filtre final: blocklist exacte d'artefacts connus ("Sous-titres realises par...",
  "Merci d'avoir regarde...", "Thank you for watching", etc.) -> tue uniquement si
  TOUTE la sortie == artefact (inoffensif pour la vraie dictee).
- `voice-transcribe-openai`: ajout `temperature: 0` (deterministe, moins
  d'hallucination) + prompt de steering enrichi (vocab FR/EN de naly: Hyprland,
  CachyOS, Claude Code, Codex, Next.js, shadcn, Higgsfield, Kabyle...).

Resultats batterie de tests (via `voice-transcribe`):
- silence -> vide en 98 ms | clip 0.2 s -> vide 40 ms | bruit -51 dB -> vide 95 ms.
- parole 0.8 s -> "En fait, il faut les completer." 713 ms.
- parole faible -28 dB -> transcription complete 1489 ms.
- parole normale -> transcription complete 1611 ms.
- test d'integration: silence pousse dans le vrai `voice-dictate-toggle` -> RIEN tape,
  presse-papier intact, note inchangee, statut "NO SPEECH DETECTED". 

Variables d'env de reglage (toutes optionnelles):
`KING_MIN_AUDIO_SEC`, `KING_MIN_PEAK_DB`, `KING_OPENAI_TRANSCRIBE_TEMPERATURE`.

### 25.5 Qualite mic interne Framework : clipping matériel (cause racine)

Symptome: naly trouvait le mic interne "pas opti". Mesure sur enregistrement reel
(48 kHz): RMS **-1.5 dB**, max **0.0 dB**, **113 453 samples ecretes**, flat factor
41.5 -> saturation massive (le signal tape le plafond, voix distordue, l'ASR colle
les mots et hallucine en fin de phrase: "Next.js, Android").

Cause: gain de capture ALSA empile a fond (HyDE/defaut):
- `Capture` = 63/63 = **+30 dB**
- `Internal Mic Boost` = 3/3 = **+30 dB**
=> jusqu'a **+60 dB** sur le mic interne.

Fix (live):
```bash
amixer -c 0 sset 'Internal Mic Boost' 0   # boost OFF
amixer -c 0 sset 'Capture' 51             # ~+21 dB au lieu de +60
sudo alsactl store                         # persiste (restaure par alsa-restore au boot)
```
Resultat mesure (take 2, meme phrase): samples ecretes **113453 -> 1**, flat factor
**0.0**, peak -14 dB, et transcription propre et COMPLETE:
"Salut, ici Ylan sur mon Framework, je teste Claude Code, Hyprland, Next.js".

Notes:
- ffmpeg a `afftdn/highpass/loudnorm/speechnorm` pour du DSP offline; testes mais
  highpass/denoise DROPPAIENT des mots -> pas retenus. loudnorm = sur (level only).
- rnnoise PipeWire dispo en conf mais plugin `.so` non installe (AUR) -> non retenu.
- Si un jour le niveau est trop bas (parle loin), option: bump `Capture` ou ajouter
  un `loudnorm` leger dans `voice-transcribe` avant l'ASR.

### 25.6 Background: TESTE OK, laisse tel quel (improvements proposes, pas appliques)

Test reel (job minimal "PONG"): background marche -> l'agent ecrit FINAL.md tout
seul, STATUS.md exit_code 0, notify-send dunst OK. Chaine prouvee de bout en bout.
`run-background.sh` laisse EXACTEMENT comme avant (naly: "remet comme avant").

Defauts reperes au test (NON appliques, a proposer/valider avec naly avant):
- `claude --print "..."` attend ~3 s sur stdin ("no stdin data received in 3s")
  -> `< /dev/null` le supprime (teste: 0 warning). Invisible, juste plus rapide.
- pas de signal "je bosse" pendant un job long; raison d'echec peu visible.

Canaux de notif background actuels (origine): dunst "Mission finie/echouee",
Waybar (king-voice-status done/error), avatar (celebrating/sulking).
Verifier un job: `ls -td ~/.king-kusaila/jobs/* | head -1` puis `cat <job>/STATUS.md`,
`cat <job>/FINAL.md`, `tail -50 <job>/claude.log`.

### 25.7 MUTEX anti-superposition (Super+V)

Bug naly: en appuyant Super+V plusieurs fois, deux sessions King se superposaient.
Cause: apres l'arret (PID supprime), un nouvel appui pendant la phase de lancement
(transcription/choix/ouverture) repartait sur un nouvel enregistrement+overlay.
Fix: lock `$STATE_DIR/busy.lock` (= PID du toggle) cree des l'arret, retire par
`trap EXIT`. En tete de script: si un busy.lock VIVANT existe -> `exit 0` (appui
ignore); si perime (process mort) -> nettoye et continue. Teste: lock vivant =
ignore (aucun record.pid), lock perime = nettoye + demarre.

### 25.8 Opacite du King: le bon levier = la fenetre/daemon, PAS l'empilement

Tentative ratee: empiler une 3e copie de frame dans le choix -> "gros background"
(naly l'a vu). REVERT total. Analyse: les PNG du choix sont deja en alpha BINAIRE
(fond alpha 0, King alpha 255) -> le King du choix est DEJA 100% opaque, rien a
densifier la (et l'empilement ne fait que reveler un fond).
Le seul King reellement pale = l'avatar "King Kusaila Visual": 0.92 (windowrule)
x 0.92 (GTK set_opacity) = ~0.85. Fix propre: windowrule -> `opacity 1.0 1.0` +
`king-kusaila-visuald` set_opacity 0.92 -> 1.0 (2 occurrences, pas le 0.01 du hide).
Puis `hyprctl reload` + restart daemon. Aucun risque de fond (juste opacite fenetre).
ATTENTION: `pkill -f king-kusaila-visuald` s'auto-matche (la commande contient le
motif) -> tuer via le pidfile `visuald.pid`, pas pkill -f.

### 25.9 Bug "prompt echo" -> fausse mission interactive sans chooser

Symptome (naly): Super+V n'a PAS demande CLI/background, il a ouvert un CLI direct,
et le mission.txt du job contenait... le PROMPT de steering OpenAI mot pour mot.
Cause: gpt-4o-transcribe renvoie parfois le PROMPT lui-meme quand l'audio est
vide/incomprehensible. Comme le prompt enrichi contenait "Claude Code", `infer_mode`
a cru a une demande interactive -> chooser saute -> CLI fantome dans
~/future/saas/transcription.
Fix (`voice-transcribe-openai`):
- prompt reduit a une simple LISTE DE VOCABULAIRE (usage correct de l'API, moins
  echo-prone) au lieu d'une instruction ("Transcription fidele...").
- garde anti-echo: si la sortie normalisee == le prompt (egal ou sous-chaine) ->
  return 1 (rejet, fallback local). Teste: echo rejete, vraie phrase tech gardee.
Rappel: l'auto-detection de mode (voix qui dit "Claude Code"/"background" -> skip
chooser) est VOULUE; le bug etait uniquement l'echo qui injectait ces mots.

### 25.10 Choix: auto-disparition 10s + dimaround impossible

- `king-kusaila-choice`: ajout d'un `GLib.timeout_add_seconds(KING_CHOICE_TIMEOUT=10,
  finish("cancel"))` -> si naly ne choisit pas, le choix s'efface seul en 10s (annule).
- Opacite King: les 2 Kings sont DEJA 100% opaques (avatar passe 0.92->1.0 ; choix =
  PNG alpha binaire + fenetre 1.0). naly: "on ne met RIEN derriere". Donc on laisse.
- `dimaround` REFUSE par Hyprland 0.55.4 ("invalid field dimaround: missing a value"),
  en syntaxe `match:title`, `title:` et `windowrulev2` (deprecated). Abandonne.

### 25.4 Ce qui n'a PAS ete fait (volontairement)

- streaming ASR (gain marginal vs ~1 s, complexite forte).
- chime/overlay pour `Super+C` (chrome, pas demande, risque d'agacer).
- paste instantane vs frappe wtype char-par-char (dependant de l'app, risque).

# 👑 Mission par TEXTE + annulation — ce qui a été ajouté

Date : 2026-06-30. Complète la couche vocale (`Super+V`) sans y toucher.

## Le besoin (naly)

1. Pouvoir **annuler** un King qui vient de pop (corriger un missclick).
2. Pouvoir lancer une mission **par texte** (copier-coller de longs prompts), pas que par la voix.
3. Garder **exactement** le même comportement ensuite : choix CLI / background, puis lancement.

## Les raccourcis (récap)

| Raccourci | Rôle |
|-----------|------|
| `Super+V` | **Voix** (inchangé) : 1er appui enregistre, 2e lance. |
| `Super+Shift+V` | **Texte** : ouvre la boîte de mission (perso animé + cartes CLI/Background). |
| `Super+Q` | **Annuler** un King en cours (REC / transcription / fenêtre de choix). Sinon : ferme la fenêtre focus (comportement normal). |
| `Super+Ctrl+V` | Gestionnaire de presse-papier cliphist (déplacé depuis `Super+Shift+V`, rien perdu). |

## Comment ça marche

### Boîte texte (`king-kusaila-textbox`, GTK)
Fenêtre dans la charte King (transparente, perso `talking` animé, panneau verre navy/or) :
- zone multi-ligne **paste-friendly** (Ctrl+V) pour les longs prompts ;
- **3 cartes** en bas : `Annuler`, `🌙 Background` (bleu), `🖥️ CLI` (rouge) — couleurs alignées sur la fenêtre de choix vocale ;
- clic sur une carte = on **force** ce mode (pas de 2ᵉ fenêtre de choix) ;
- clavier : `Ctrl+Entrée` → CLI, `Échap` → annuler.
- Sortie : `1re ligne = mode choisi`, le reste = la mission.

### Le pont vers la pipeline existante
`king-kusaila-text` (lancé par `Super+Shift+V`) :
1. capture le **moniteur actif** au moment du raccourci (pour que la fenêtre CLI s'ouvre **sur l'écran de l'utilisateur**) ;
2. ouvre la boîte, récupère `mode` + `mission` ;
3. appelle `king-kusaila-toggle --text --mon <moniteur> --mode <mode> "<mission>"`.

`king-kusaila-toggle` a été refactoré : toute la logique de lancement (job, system.md,
run-interactive.sh / run-background.sh, ouverture kitty) est dans une **fonction unique
`launch_mission(mission, launch_mon, forced_mode)`**, partagée par la voix ET le texte.
→ Un seul code de lancement, pas de duplication. La carte CLI ouvre kitty via
`hyprctl dispatch exec open-cli.sh` **exactement comme `Super+V`**.

### Annulation (`king-kusaila-cancel`)
- Détecte si King est actif (record.pid / busy.lock / choice.pid vivants).
- Si oui → tue proprement (SIGINT pour que `pw-record` ferme son `.wav`, puis escalade
  TERM → KILL si ça s'accroche), nettoie l'état, cache l'overlay.
- Si non → `hyprctl dispatch killactive` (Super+Q garde son rôle habituel).

## Détails corrigés en route

- **Fenêtre CLI invisible** : elle s'ouvrait sur le moniteur de la boîte texte, pas celui de
  l'utilisateur. Fix = capture du moniteur focalisé au moment du raccourci, propagé jusqu'à
  `open-cli.sh` (`--mon`).
- **Opacité** : la règle globale HyDE `active_opacity = 0.92` dimmait la boîte → ajout de
  `windowrule = opacity 1.0 1.0, match:title ^(King Kusaila Text)$` + panneau plus solide.
- **Nom du dossier projet** : passait à 1 mot → maintenant **2 mots de contenu** (mots vides
  sautés). Ex : « crée un site de recettes de cuisine » → `recettes-cuisine`.

## Fichiers

- `bin/king-kusaila-textbox` — la boîte GTK (nouveau)
- `bin/king-kusaila-text` — pont rofi/zenity/textbox → pipeline (nouveau)
- `bin/king-kusaila-cancel` — annulation intelligente (nouveau)
- `bin/king-kusaila-toggle` — refactor `launch_mission()` + branche `--text`
- `hypr/userprefs-king.conf` — bindings + windowrules (déployé via `install.sh`)

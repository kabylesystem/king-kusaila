# Récupération & persistance face à HyDE

HyDE **régénère** certaines configs à chaque changement de thème → ça écrase les customisations.
Ce dossier + le watcher systemd les réappliquent **automatiquement**.

## Ce que HyDE écrase (et où est la vérité)

| Custo | Fichier écrasé par HyDE | Source durable / réinjection |
|---|---|---|
| Modules Waybar King (🔴 REC + 👑 couronne répondeur) + bouton DND | `~/.config/waybar/config.jsonc` (régén selon le layout du thème) | `desktop/waybar/layouts/naly-top.jsonc` (layout canonique) + `desktop/waybar/modules/king.jsonc` (définitions, toujours incluses via `modules/*json*`) |
| Glass des notifs dunst (sombre, translucide ~15 %, sans bordure) | `~/.cache/hyde/wallbash/dunst.conf` (couleurs du thème, **volatile**) | bloc `naly-glass` réécrit par le script de restauration |

## Ce qui survit déjà tout seul (ne pas toucher)

- `~/.config/hypr/userprefs.conf` — bordure 0 globale, opacités par-app, **layerrule blur** sur le namespace `notifications` (c'est lui qui fait le flou du glass).
- `~/.config/dunst/dunst.conf` — taille des notifs (icône 32px), padding, coins, skip des popups Claude Code, OSD volume dompté. Sourcé par HyDE dans `dunstrc` (gagne sur le template).
- `~/.config/waybar/user-style.css` — CSS du badge `#custom-king-voice.recording` (REC rouge pulsé).
- `~/.claude/settings.json` — `preferredNotifChannel: notifications_disabled` (coupe la notif desktop de Claude Code).

## Le mécanisme de persistance

- `bin/naly-desktop-restore` — script idempotent : si King manque de la barre → réapplique `naly-top.jsonc` + restart waybar ; si le marqueur `naly-glass` manque du cache → réécrit le glass + régénère `dunstrc` + `dunstctl reload`. N'écrit que si nécessaire (pas de boucle avec le watcher).
- `desktop/systemd/naly-desktop-restore.path` — watcher : surveille `config.jsonc` et le cache glass dunst. Dès que HyDE les régénère (= switch de thème), il lance le service.
- `desktop/systemd/naly-desktop-restore.service` — oneshot : `sleep 2` (laisse HyDE finir) puis lance le script.

Résultat : **peu importe le thème HyDE choisi, King + DND + glass reviennent tout seuls en ~3 s.**

## Installer sur une machine neuve

```bash
# 1. modules + layout waybar
cp desktop/waybar/modules/king.jsonc   ~/.config/waybar/modules/king.jsonc
cp desktop/waybar/layouts/naly-top.jsonc ~/.local/share/waybar/layouts/naly-top.jsonc
# 2. dunst (taille/skip ; le glass est posé par le script)
cp desktop/dunst/dunst.conf ~/.config/dunst/dunst.conf
# 3. watcher systemd
cp desktop/systemd/naly-desktop-restore.{path,service} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now naly-desktop-restore.path
# 4. boot : double sécurité dans ~/.config/hypr/userprefs.conf
#    exec-once = sleep 4 && /home/<user>/.local/bin/naly-desktop-restore
# 5. première application
~/.local/bin/naly-desktop-restore
```

## Désactiver (si un jour tu veux un autre layout de barre)

```bash
systemctl --user disable --now naly-desktop-restore.path
```

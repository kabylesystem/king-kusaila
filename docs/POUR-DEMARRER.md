# Pour démarrer

Ce qu'il faut installer pour reproduire ce setup, dans l'ordre, avec les pièges rencontrés.

Trois parcours selon l'envie : tout, le bureau seul, ou juste le harness agent.

---

## Parcours A : juste le harness agent (30 minutes, sans changer d'OS)

Le plus rentable. Ça marche sur n'importe quelle distribution, sur macOS, dans WSL.

1. **Installer Claude Code** et s'authentifier.
2. **Créer `~/.claude/CLAUDE.md`** avec les règles permanentes. Commencer petit : le format
   de réponse voulu, et deux ou trois règles de comportement. Ça grossit tout seul.
3. **Créer `~/.claude/skills/`**. Un dossier par domaine, un `SKILL.md` dedans avec un
   en-tête `name` et `description` (c'est la description qui déclenche le chargement).
4. **Prendre l'habitude** : dès qu'une leçon est apprise ou une préférence exprimée,
   l'écrire dans le skill concerné, immédiatement.

C'est tout. Le reste du document est du confort.

---

## Parcours B : le bureau (une soirée)

### L'OS

**CachyOS**, installateur graphique classique. Choisir Hyprland au moment de la sélection
du bureau, ou installer HyDE par-dessus après coup.

Alternative : n'importe quelle Arch avec Hyprland. Le gain CachyOS est réel mais modeste,
et tout ce qui suit fonctionne à l'identique.

Vérifier après installation que l'ordonnanceur alternatif tourne :

```bash
cat /sys/kernel/sched_ext/root/ops     # doit afficher lavd_...
```

S'il est vide, l'activer :

```bash
sudo systemctl enable --now scx_loader.service
```

### La base de bureau

**HyDE** donne une base Hyprland cohérente et thémable. On part de là, puis on remplace les
morceaux qui gênent.

Pièges connus :

- Les fichiers fournis par HyDE sont **écrasés à chaque mise à jour**. Toute modification
  doit être sauvegardée ailleurs (un dépôt git), sinon elle disparaît.
- Les descriptions de raccourcis de HyDE contiennent des crochets, ce qui casse la
  sérialisation JSON de `hyprctl binds`. Un script du thème boucle alors à l'infini. Si le
  compositeur devient anormalement gourmand, chercher les processus `hint-hyprland.py`.

### Les dépendances

```bash
sudo pacman -S pipewire wtype wl-clipboard jq ffmpeg python-gobject gtk3 \
               gtk-layer-shell dunst kitty quickshell whisper.cpp \
               libva-utils intel-media-driver
```

`whisper.cpp` sert de repli local à la transcription. Télécharger au moins un modèle :

```bash
# large-v3-turbo quantifié : le meilleur compromis mesuré sur cette machine
# 8,6 s pour une dictée de 29 s, contre 12,9 s pour le modèle small
```

### Le dépôt

```bash
git clone git@github.com:kabylesystem/king-kusaila.git
cd king-kusaila
./install.sh                    # symlinks bin/* vers ~/.local/bin
cp config/openai.env.example ~/.config/king-kusaila/openai.env
chmod 600 ~/.config/king-kusaila/openai.env
cat hypr/userprefs-king.conf >> ~/.config/hypr/userprefs.conf
hyprctl reload
```

Remplir la clé OpenAI dans `openai.env`. Sans elle, la transcription bascule sur le modèle
local (plus lent, un peu moins précis, mais fonctionnel).

---

## Parcours C : les rigs, à la carte

Chacun est indépendant, aucun n'est nécessaire aux autres. Les lire dans
`~/.claude/skills/<nom>/SKILL.md`.

| Rig | Ce qu'il faut en plus |
|---|---|
| Dictée vocale | une clé OpenAI, ou seulement whisper.cpp |
| Cast TV | une TV compatible DLNA sur le même réseau |
| Sideload iOS | un identifiant Apple gratuit, `usbmuxd`, `netmuxd` |
| VPS | un serveur (Hetzner ici), Coolify, Traefik |
| Mentor | un dépôt git privé, un bot Telegram |

---

## Les réglages qui valent le détour

Indépendants du reste, applicables partout, mesurés sur cette machine.

### Le flou du compositeur

Dans la configuration Hyprland :

```
decoration {
    blur {
        enabled = true
        xray = true
    }
}
```

`xray` fait flouter le fond d'écran au lieu de refloutter chaque fenêtre empilée derrière.
Rendu identique à l'œil, coût GPU divisé par 2,6 (mesuré : 39,7 % à 19,1 %, et 2,6 W à
1,0 W au repos).

### Le décodage vidéo matériel dans le navigateur

Beaucoup de navigateurs décodent la vidéo en logiciel sur Linux alors que le matériel sait
le faire. Dans `~/.config/<navigateur>-flags.conf` :

```
--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiIgnoreDriverChecks
```

Ne pas copier ces noms aveuglément : ils changent selon les versions. Les lire dans le
binaire :

```bash
strings /chemin/vers/navigateur | grep -E '^(Vaapi|AcceleratedVideoDecode)'
```

Vérifier ensuite que le pilote est bien chargé :

```bash
grep -c iHD_drv_video /proc/$(pgrep -f 'type=gpu-process' | head -1)/maps
```

Effet mesuré pendant une vidéo : de 83-87 °C à 63 °C, ventilateur de 8500 à 2900 tr/min.

### Les modules de barre

Si un module de barre a déjà un **signal** de rafraîchissement (le script qui change l'état
envoie `pkill -RTMIN+N waybar`), son intervalle de scrutation peut monter à 8 ou 10 secondes
sans rien perdre. Mesuré : de 164 à 47 lancements de script par minute, et la barre passe de
11,5 % à 1,7 % de CPU.

### Chercher les processus fantômes

À faire de temps en temps. Un processus abandonné ne se voit jamais dans un top instantané :

```bash
python3 -c "
import glob, os
hz=os.sysconf('SC_CLK_TCK'); rows=[]
for p in glob.glob('/proc/[0-9]*/stat'):
    try:
        f=open(p).read(); pid=p.split('/')[2]
        r=f[f.rindex(')')+2:].split()
        cpu=(int(r[11])+int(r[12]))/hz
        cmd=open(f'/proc/{pid}/cmdline').read().replace(chr(0),' ')[:60]
        if cpu>60: rows.append((cpu,cmd))
    except: pass
rows.sort(reverse=True)
up=float(open('/proc/uptime').read().split()[0])
for c,cmd in rows[:15]: print(f'{c/60:7.1f} min ({c/up*100:4.1f}%)  {cmd}')"
```

Signature d'un fantôme : `parent=1` (systemd l'a adopté, donc son lanceur est mort), vieux
de plusieurs heures, aucune connexion réseau, et pourtant il consomme encore.

---

## Ce qu'il faut savoir avant de se lancer

**Hyprland casse parfois entre deux versions.** C'est un projet qui bouge vite. Garder une
configuration versionnée et savoir revenir en arrière.

**Arch demande de l'attention.** Jamais de mise à jour complète automatique. Lire les
annonces avant les grosses montées de version.

**Un agent avec les pleins pouvoirs a besoin d'un filet.** Le filet, c'est git, pas la
prudence. Tout ce qui compte doit être commité au fur et à mesure.

**Le plus dur n'est pas l'installation.** C'est l'habitude d'écrire la leçon au moment où
elle est apprise. Sans ça, le système ne s'améliore pas, il se contente d'exister.

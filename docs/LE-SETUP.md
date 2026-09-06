# Le setup de kabylesystem

Un Framework 13 sous CachyOS, piloté à la voix, où un agent IA a les clés de la machine.
Ce document explique comment c'est construit, pourquoi ces choix, et ce qui marche
vraiment après plusieurs mois d'usage quotidien.

Écrit pour quelqu'un qui voudrait comprendre le système ou s'en inspirer.

---

## 1. La machine

| | |
|---|---|
| Portable | Framework 13, réparable et modulaire (ports interchangeables) |
| CPU | Intel Core Ultra 5 125H, 18 threads (architecture hybride P/E/LP-E) |
| RAM | 16 Go |
| Écran | 2880x1920 à 120 Hz, ratio 3:2 |
| OS | CachyOS (Arch optimisée) |
| Noyau | `linux-cachyos` 7.1, compilé LTO + AutoFDO + Propeller |
| Ordonnanceur | `scx_lavd` (sched-ext, pensé desktop) |
| Bureau | Hyprland 0.56 (Wayland, tiling) sur base HyDE |
| Terminal | kitty |
| Shell | zsh en interactif, fish pour ses fonctions perso |

**Pourquoi Framework** : les pièces se changent une par une. La carte mère, le clavier,
les ports. Un laptop qu'on garde cinq ans au lieu d'en racheter un.

**Pourquoi CachyOS plutôt qu'Arch pure** : mêmes paquets, même AUR, même rolling release,
mais les binaires sont compilés pour les CPU modernes (`x86-64-v3`) et le noyau embarque
des ordonnanceurs alternatifs. Le gain réel est modeste (2 à 10 % sur du calcul), mais
`scx_lavd` change vraiment le ressenti : le bureau reste réactif même quand un cœur est
saturé. Mesuré en vrai : avec un processus qui bloquait un cœur pendant des heures,
l'interface restait utilisable.

**Ce que CachyOS ne fait pas**, et c'est important à savoir : un noyau optimisé ne
compense pas une application qui boucle, ne réduit pas la chaleur d'un décodage vidéo,
et n'agrandit pas le radiateur d'un 13 pouces. Les vrais gains de performance mesurés sur
cette machine venaient tous de réglages applicatifs, jamais de la distribution.

---

## 2. La philosophie

Trois idées structurent tout le reste.

### Le clavier plutôt que la souris

Hyprland est un gestionnaire de fenêtres en tuiles : les fenêtres se rangent toutes
seules, on navigue au clavier. Pas de fenêtres qui se chevauchent, pas de temps perdu à
redimensionner. Chaque geste fréquent a un raccourci.

### La voix plutôt que la frappe

Deux raccourcis résument le système : `Super+C` dicte du texte n'importe où, `Super+V`
donne une mission à un agent. Parler est plus rapide que taper, surtout pour formuler une
intention longue.

### L'agent a les clés

Claude Code tourne avec les permissions complètes sur la machine. Il lit, écrit, installe,
déploie, diagnostique. Ce n'est pas une fenêtre de chat à côté du travail : c'est un
opérateur qui agit sur le système. Tout le reste du setup existe pour rendre ça sûr et
efficace.

---

## 3. Les deux gestes qui définissent le système

### `Super+C` : la dictée

Un appui démarre l'enregistrement, un appui l'arrête. Le texte est transcrit et **tapé
dans la fenêtre où le raccourci a été lancé**, même si on est parti ailleurs entre-temps.
Deux appuis rapprochés envoient (touche Entrée).

La chaîne complète :

```
pw-record (micro interne)
   -> voice-audio-prep   normalisation, tri parole/silence, mesures
   -> gpt-4o-transcribe  (repli whisper.cpp local si l'API échoue)
   -> filtres            langue, hallucinations connues
   -> frappe             pty du terminal, ou clavier virtuel Wayland
```

Ce qui rend la chose fiable, ce sont les garde-fous appris à la dure :

- **Le tri parole/silence** : un seuil absolu et un seuil relatif, chacun insuffisant seul.
  Un micro qui capte du bruit ambiant ne doit rien écrire plutôt que d'inventer du texte.
- **Le gain analogique** : un micro saturé produit du charabia, pas du silence. Le rig
  mesure toujours avant de conclure, jamais de niveau audio deviné.
- **La livraison sans vol de focus** : dans un terminal, le texte passe par le pty de kitty,
  donc rien ne bouge à l'écran. Pour les autres fenêtres, Wayland impose le focus pour
  écrire : plutôt que de l'arracher, le texte attend et part quand on revient dessus.

### `Super+V` : la mission vocale

On parle une tâche, elle est transcrite, puis Claude Code la reçoit et l'exécute. Deux
modes : en arrière-plan (silencieux, notification à la fin) ou dans un terminal visible.

Chaque mission crée un dossier durable dans `~/.king-kusaila/jobs/<date>-<slug>/` avec la
mission, son statut, le log complet et un rapport final. Rien ne se perd quand une session
se ferme.

---

## 4. Les interfaces maison

Le bureau de base (HyDE) a été progressivement remplacé par des surfaces écrites en QML
pour **Quickshell**, dans une direction visuelle cyberpunk cohérente : fond très sombre,
accent vert citron, rose pour les alertes, verre translucide, coins arrondis.

| Interface | Remplace | Raccourci |
|---|---|---|
| `naly-session` | wlogout (menu power) | Ctrl+Alt+Suppr |
| `naly-control` | blueman + nm-applet (Wi-Fi/BT) | Super+N |
| `naly-clipboard` | le sélecteur cliphist | Super+V du presse-papier |
| `naly-notify` | le centre de notifications | aucun |
| `naly-explorer`, `naly-ask`, `naly-audio`, `naly-calendar`, `naly-mic`, `naly-osd` | divers | aucun |

**Pourquoi réécrire ces interfaces** : les outils GTK par défaut ne suivent pas le thème,
s'ouvrent en fenêtres flottantes qui cassent le tiling, et sont lents. Une surface
Quickshell s'affiche en couche par-dessus le bureau, respecte la langue visuelle du reste,
et se ferme d'un Échap.

**Attention au piège** : cette logique a une limite. Un explorateur de fichiers complet a
été réécrit en QML alors que Nautilus existe et fait le travail. La leçon en a été tirée
et gravée : avant d'écrire quoi que ce soit de conséquent, chercher le projet open source
qui fait déjà 60 à 80 % du travail.

### La barre

Waybar, avec des modules maison :

- **profil thermique** cliquable (Silencieux / Équilibré / Perf), qui affiche une moyenne
  lissée sur une minute plutôt que la valeur instantanée (le CPU fait des rafales à 4 GHz
  qui montent à 99 °C pendant quelques millisecondes : afficher l'instantané donne
  l'impression d'une machine en surchauffe permanente)
- **anti-bug** : un bouton qui diagnostique et corrige les ralentissements en un clic
- **état de la dictée**, **consommation Claude**, **certificats iOS**, **ne pas déranger**

Règle de conception apprise : un module de barre qui a déjà un **signal** de rafraîchissement
n'a pas besoin d'être interrogé toutes les secondes. En appliquant ça, la barre est passée
de 164 à 47 lancements de script par minute, et de 11,5 % à 1,7 % de CPU, sans perdre une
miliseconde de réactivité.

---

## 5. Les rigs

Des sous-systèmes autonomes, chacun avec son skill de documentation.

### Stremio TV

Caster un film sur n'importe quelle TV DLNA, avec sous-titres français **resynchronisés
automatiquement** et enchaînement automatique des épisodes. Le cast intégré de Stremio
étant factice, le rig envoie lui-même les requêtes SOAP à la télé. Trois services systemd
gèrent la détection de lecture, le cast, la précharge des épisodes suivants.

### Sideload iOS

Installer des applications patchées sur un iPhone depuis Linux, avec un compte Apple
**gratuit**. Signature en profondeur, contournement de la limite des app-groups, et surtout
un rafraîchissement automatique par timers : les certificats gratuits expirent au bout de
7 jours, le rig re-signe tout seul, sans câble, par Wi-Fi.

### La box

Un VPS Hetzner piloté par API. Astuce notable : `sslip.io` résout n'importe quelle IP encodée
dans un nom de domaine, donc on obtient du HTTPS public avec certificat Let's Encrypt
**sans acheter de domaine**. Les jobs longs et les agents 24/7 tournent là.

### Le mentor

Un cerveau markdown versionné dans un repo privé, lu et écrit par trois canaux : un bot
Telegram, Claude Code, et un distillateur qui transforme les conversations ChatGPT en
notes. Le fichier `moi/vision.md` garde la trajectoire datée des envies et des décisions.

### Le cockpit 42

Pour les projets de l'école 42 : un workspace découpé en trois zones (agent tuteur à
gauche, Neovim en haut à droite, compilation et norminette en direct en bas à droite).
`Ctrl+S` sauve, envoie `check` à l'agent et lui rend le focus : plus aucune capture
d'écran ni erreur recopiée à la main.

---

## 6. Ce qui a été appris sur la performance

Une journée entière de chasse a fait passer la machine de **104 °C et 9362 tr/min** à
**53 °C et 1844 tr/min**. Le détail est dans `PERF-2026-08-26.md`, mais la méthode vaut
plus que les chiffres.

**Les vraies causes trouvées** :

1. Une application de DJ qui analysait la bibliothèque musicale en boucle depuis des heures,
   un cœur saturé en continu. Sur un châssis de 13 pouces, un seul cœur à fond dissipe
   autant qu'un jeu.
2. Treize processus bloqués dans une boucle infinie, qui interrogeaient le compositeur
   **chaque seconde depuis 39 heures**. Cause racine : un script qui faisait
   `except JSONDecodeError: sleep(1)` à l'intérieur d'un `while True`, sur une sortie JSON
   malformée. Le compositeur était devenu le premier consommateur de la machine.
3. Un navigateur headless orphelin qui tournait dans le vide depuis 9 heures : 243 Mo,
   14 minutes de CPU, plus aucun programme pour le piloter.
4. Le flou du compositeur qui refloutait chaque fenêtre empilée au lieu du seul fond
   d'écran. Un réglage (`blur:xray`) a divisé le coût par 2,6, **à rendu identique**.

**Les fausses pistes, tout aussi instructives** : radiateur encrassé (réfuté, la température
chutait de 15 °C en 50 secondes ventilateur à fond), CPU qui ne dort jamais (normal écran
allumé), écran 120 Hz coupable (aucun gain mesuré en 60 Hz).

**La technique qui a tout débloqué** : un processus fantôme ne se voit jamais dans un top
CPU instantané, parce qu'il consomme peu à un instant donné mais tourne depuis des heures.
Il faut classer par **CPU cumulé depuis le démarrage**, en lisant `/proc/<pid>/stat`.

**La règle de méthode** : mesurer avant et après chaque changement, isolément. Se méfier
des mesures polluées (une charge de fond qui bouge fausse tout). Et remettre le réglage
d'origine quand le gain n'est pas au rendez-vous, plutôt que de garder un changement
« qui ne peut pas faire de mal ».

---

## 7. Le harness

C'est la partie la plus intéressante du système, et elle a son propre document :
**`LE-HARNESS.md`**.

En résumé : Claude Code tourne avec 47 skills, deux hooks, une mémoire persistante et un
ensemble de règles de comportement affûtées par les erreurs. Ce n'est pas de la
configuration cosmétique, c'est ce qui fait la différence entre un assistant qui répond et
un opérateur qui livre.

---

## 8. Ce qui n'est pas fait, ou reste fragile

Par honnêteté, parce qu'un document qui ne liste que les réussites ne sert à personne.

- **Les correctifs sur les fichiers fournis par HyDE** (le thème de bureau) peuvent être
  écrasés à la prochaine mise à jour. Ils sont sauvegardés dans le repo, mais rien ne les
  réapplique automatiquement.
- **Le presse-papier ne garde pas de dates** avant septembre 2026 : `cliphist` ne stocke
  aucun horodatage, un service maison a été ajouté pour dater les nouvelles entrées, mais
  l'historique passé est définitivement sans date.
- **Plusieurs services de test empilés** ont traîné des semaines (six copies du même script
  écoutant sur six ports). Un rig itératif laisse des restes : il faut chasser les doublons
  périodiquement.
- **Les interfaces Quickshell ne sont pas packagées** : elles vivent dans `~/.config`, sans
  installateur ni tests.
- **La barre reste le point de fragilité** : un module qui renvoie du JSON invalide casse
  l'affichage. Un service de garde la relance si elle disparaît.

---

## 9. Pourquoi ce setup vaut le coup

Ce n'est pas une collection de dotfiles. Trois propriétés le distinguent.

**Tout est réversible et versionné.** Les scripts vivent dans un repo git, reliés par
symlinks depuis `~/.local/bin`. Les configurations touchées sont copiées dans le repo. Une
bêtise se défait avec un `git revert`, ce qui est arrivé et a fonctionné.

**Les leçons sont écrites, pas mémorisées.** Chaque panne diagnostiquée, chaque fausse
piste, chaque préférence exprimée finit dans un fichier de skill avec ses mesures. Le
système ne réapprend pas deux fois la même chose, et surtout : il n'y a pas besoin de se
souvenir.

**L'ambiant plutôt que l'attention.** Les rappels arrivent sur Telegram, les jobs tournent
sur un VPS, la machine se diagnostique elle-même en un clic, les certificats se renouvellent
sans intervention. Le principe : ce qui peut tourner sans y penser ne doit pas demander d'y
penser.

---

## 10. Reproduire tout ça

`POUR-DEMARRER.md` liste ce qu'il faut installer et dans quel ordre, avec les pièges
rencontrés.

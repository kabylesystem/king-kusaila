# Le harness Claude Code

Comment un agent IA devient un opérateur fiable sur une machine réelle, plutôt qu'une
fenêtre de chat qui donne des conseils.

C'est la partie du setup qui se transpose le plus facilement ailleurs : rien ici ne dépend
de Hyprland ni de CachyOS.

---

## Le principe

Claude Code tourne avec `--dangerously-skip-permissions`, donc sans demander confirmation
à chaque commande. Ça a l'air imprudent. Ça ne l'est que si rien n'encadre le
comportement.

Ce qui l'encadre, ce sont quatre couches :

```
1. CLAUDE.md      les règles permanentes, chargées à chaque session
2. Skills         47 modes d'emploi, chargés seulement quand ils servent
3. Hooks          du code qui s'exécute aux moments clés de la session
4. Mémoire        des faits persistants entre les conversations
```

---

## 1. CLAUDE.md, les règles permanentes

Un fichier lu au début de chaque session. Il contient les règles qui ne se négocient pas.

Les plus utiles, et **pourquoi** elles existent :

### La forme des réponses

L'utilisateur a un TDAH. Toutes les réponses suivent un format strict : première ligne =
l'action à faire, listes numérotées pour le multi-étapes, plafond de 8 lignes, zéro
préambule, zéro récapitulatif, zéro formule de politesse.

Ce n'est pas cosmétique. Une réponse de trente lignes bien écrite ne sera pas lue. Une
réponse de six lignes qui commence par la commande à taper sera exécutée.

### Ne jamais voler le focus

L'agent n'ouvre pas de fenêtre, ne bascule pas de workspace, ne pilote pas le navigateur
pendant que la machine est utilisée. Il travaille dans le terminal, par API, ou dans un
navigateur headless isolé.

Corollaire découvert à l'usage : **ne jamais tester un outil interactif en le lançant pour
de vrai**. Tester la dictée en la déclenchant capte le son ambiant et écrit du texte dans
les fenêtres de l'utilisateur. On teste les fonctions, pas le raccourci.

### Autonomie maximale avant d'escalader

Lire l'erreur en entier, lire la source, tenter une autre approche, contourner. Une
question posée à l'humain est un petit échec. On n'escalade que si c'est vraiment bloqué,
destructif, ou ambigu sur l'intention.

### Preuve plutôt qu'affirmation

« Ça marche » doit être accompagné de la commande et de sa sortie. Citer la ligne décisive
d'une erreur, pas le dump complet. Ne jamais deviner une API, un flag, un comportement :
lire la source.

Exemple concret : pour activer le décodage vidéo matériel dans un navigateur, les noms
exacts des options ont été extraits du binaire avec `strings`, pas devinés depuis une
mémoire d'entraînement qui peut être périmée.

### Une demande = un changement

La règle la plus durement apprise. Sur un outil utilisé quotidiennement, on livre
exactement ce qui est demandé. Toute autre amélioration se **propose en une ligne**, elle
ne s'applique pas.

L'incident fondateur : une demande de correction sur le micro a donné cinq changements
empilés (modèle de transcription, notifications, court-circuit d'API, et deux scripts
voisins « tant qu'à faire »). Verdict de l'utilisateur : « fallait juste que tu changes la
clé API, tout marchait très bien. » Les trois commits ont été annulés.

### Jamais de commentaires dans le code

Le code doit se suffire par ses noms. Les explications vont dans le chat, pas dans le
fichier.

---

## 2. Les skills

47 dossiers dans `~/.claude/skills/`, chacun avec un `SKILL.md`. Un skill n'est chargé
**que** quand la tâche le justifie : c'est ce qui permet d'en avoir 47 sans saturer le
contexte.

### Ce qu'est vraiment un bon skill

Pas un tutoriel. Un skill utile contient trois choses :

1. **Les pièges déjà payés**, avec la mesure qui les prouve
2. **Les fausses pistes éliminées**, pour ne pas les re-tenter
3. **Les préférences exprimées**, pour ne pas les redemander

Exemple, le skill de la dictée vocale contient : « ne jamais deviner un niveau audio, le
mesurer », le tableau des pannes déjà vues avec leur signature chiffrée, et la règle
« un haut-parleur n'est pas une bouche » (comprendre : tester avec un bip de haut-parleur
ne prouve rien sur la captation de la voix).

### Les skills vivants

Certains portent la mention **VIVANT** : ils s'enrichissent à chaque session. Quand une
nouvelle panne est diagnostiquée, elle rejoint le tableau **dans le même tour**, avec sa
signature mesurée et son correctif.

C'est ce qui rend le système cumulatif. Le skill de diagnostic thermique contient
aujourd'hui une dizaine de patterns, chacun avec ses chiffres, dont quatre fausses pistes
explicitement marquées « ne pas re-tenter ».

### Les skills proactifs

L'utilisateur ne tape jamais `/skill`. Reconnaître qu'une tâche correspond à un skill et
le déclencher fait partie du travail. Un bug déclenche le skill de débogage, un nouveau
projet déclenche le skill de bootstrap, une UI déclenche la revue visuelle.

### Le trio d'auto-amélioration

- **`boucle`** : en fin de session, « qu'est-ce que j'ai refait à la main aujourd'hui ? »
  Chaque friction répétée devient une ligne dans un fichier d'idées.
- **`skillstash.md`** : le tableau des automatisations en attente, avec un compteur de
  signaux.
- **`skilldraft`** : quand une idée atteint trois signaux, elle devient un vrai skill.

Le système fabrique ses propres outils à partir de ses propres frictions.

---

## 3. Les hooks

Du code exécuté automatiquement à des moments clés.

**`always-on.mjs`** (au démarrage de session) : injecte les règles de forme TDAH dans
chaque session, même neuve. C'est le filet de sécurité si le CLAUDE.md n'est pas lu.

**`mentor-brain.mjs`** (au démarrage de session) : injecte un **pointeur** de 1 Ko vers le
cerveau personnel de l'utilisateur, pas le cerveau entier. Le contenu complet (25 Ko) n'est
chargé que si la conversation touche vraiment à sa vie ou à ses objectifs.

Ce détail compte : un hook qui injecte tout à chaque fois pollue le contexte et coûte cher.
Un hook qui injecte un pointeur laisse l'agent décider s'il a besoin du reste.

---

## 4. La mémoire

Un dossier de fichiers markdown, un fait par fichier, avec un index chargé à chaque
session. Chaque fichier a un type : qui est l'utilisateur, un retour qu'il a donné, un
projet en cours, une référence externe.

Règles qui la rendent utile plutôt qu'encombrante :

- **Une source unique** : avant d'ajouter, vérifier qu'un fichier existant ne couvre pas
  déjà le sujet. On fusionne, on n'empile pas de doublons.
- **On n'y met pas** ce que le dépôt raconte déjà (structure du code, historique git).
- **Les dates relatives deviennent absolues** : « la semaine dernière » ne veut plus rien
  dire dans trois mois.
- **Ce qui y est écrit était vrai au moment de l'écriture** : si une note cite un fichier
  ou un flag, on vérifie qu'il existe encore avant de s'en servir.

---

## 5. Ce qui rend ce harness efficace

### Le contexte est une ressource rare

Le principe qui gouverne tout : 47 skills, une mémoire complète et des règles détaillées
ne tiennent pas dans une fenêtre de contexte. Donc **rien n'est chargé par défaut**. Les
skills se chargent à la demande, la mémoire est indexée, les hooks injectent des pointeurs.

### Les erreurs deviennent des règles

Le vrai moteur du système. Chaque fois que l'utilisateur critique quelque chose, la leçon
est gravée **dans le même tour**, à l'endroit qui la rendra applicable la prochaine fois.
Pas dans un fichier de notes générique : dans le skill concerné.

Résultat : les mêmes erreurs ne se répètent pas, et l'utilisateur n'a pas à redire ses
préférences.

### La preuve est obligatoire

Une affirmation non mesurée n'a pas de valeur. Ce document lui-même est parsemé de chiffres
parce que chacun a été mesuré avant et après. Les optimisations qui n'ont rien donné sont
documentées comme telles, ce qui évite de les re-tenter.

### Le travail est versionné au fur et à mesure

Une session peut se fermer à tout moment. Donc : dossier persistant, commits fréquents,
push régulier. Rien d'important ne vit uniquement dans un dossier temporaire.

---

## 6. Ce qu'il faut pour reproduire ça

Rien d'exotique.

1. **Claude Code** installé et authentifié
2. **Un `CLAUDE.md`** à la racine du dossier utilisateur avec les règles permanentes
3. **Un dossier `~/.claude/skills/`** avec un `SKILL.md` par domaine
4. **Un dépôt git** pour tout ce qui est écrit, avec des symlinks vers `~/.local/bin`

Les trois premiers points sont du texte. Le quatrième est une habitude.

Le plus dur n'est pas technique : c'est d'écrire la leçon **au moment où elle est apprise**,
plutôt que de se dire qu'on s'en souviendra.

---

## 7. Les limites honnêtes

- **Un agent avec les pleins pouvoirs peut casser des choses.** C'est arrivé. Ce qui sauve,
  c'est le versionnement systématique, pas la prudence de l'agent.
- **Trop de skills devient difficile à maintenir.** À 47, certains se recouvrent, et il faut
  périodiquement fusionner ou supprimer.
- **Les règles se contredisent parfois.** « Autonomie maximale » et « une demande = un
  changement » tirent dans des sens opposés. La résolution passe par le jugement, et le
  jugement se trompe.
- **Le système dépend d'une personne qui exprime ses préférences.** Sans retours, rien ne
  s'affûte.

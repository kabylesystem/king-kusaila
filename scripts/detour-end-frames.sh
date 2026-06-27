#!/usr/bin/env bash
# Detoure le fond des frames d'animation "celebrating" (done) et "sulking" (error).
# Contexte: ces webm ont un alpha VP9 OPAQUE (fond gris ~209,208,211 baked-in,
# alpha moyen ~238), contrairement a talking/dancing deja detourees (~100).
# Methode validee: floodfill alpha depuis les bords (le King + flocons sont d'une
# autre couleur, donc preserves). Backup .bak-<set> cree une fois, reversible.
set -euo pipefail
FR="${1:-$HOME/.king-kusaila/assets/frames}"
SEEDS=(-draw 'alpha 2,2 floodfill' -draw 'alpha 558,2 floodfill'
       -draw 'alpha 2,750 floodfill' -draw 'alpha 558,750 floodfill'
       -draw 'alpha 280,4 floodfill' -draw 'alpha 4,400 floodfill'
       -draw 'alpha 556,400 floodfill' -draw 'alpha 280,748 floodfill')
for st in celebrating sulking; do
  [ -d "$FR/$st" ] || continue
  [ -d "$FR/.bak-$st" ] || cp -r "$FR/$st" "$FR/.bak-$st"
  for f in "$FR/$st"/*.png; do
    magick "$f" -alpha set -fuzz 14% -fill none "${SEEDS[@]}" "$f"
  done
  echo "detoure: $st"
done

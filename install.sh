#!/usr/bin/env bash
# Installe King Kusaila sur cette machine : symlink bin/* -> ~/.local/bin.
# Idempotent. Sauvegarde tout fichier existant non-symlink en .bak.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.local/bin"
mkdir -p "$DEST"

for f in "$REPO_DIR"/bin/*; do
  name="$(basename "$f")"
  target="$DEST/$name"
  if [[ -e "$target" && ! -L "$target" ]]; then
    cp -a "$target" "$target.bak"
    echo "backup: $name -> $name.bak"
  fi
  ln -sfn "$f" "$target"
  chmod +x "$f"
  echo "link:   $name"
done

echo
echo "Fait. Étapes restantes :"
echo "  1. cp config/openai.env.example ~/.config/king-kusaila/openai.env && chmod 600 ~/.config/king-kusaila/openai.env  (puis remplir la clé)"
echo "  2. cat hypr/userprefs-king.conf >> ~/.config/hypr/userprefs.conf && hyprctl reload"
echo "  3. assets : regénérer les frames PNG depuis assets/transparent/*.webm si besoin."

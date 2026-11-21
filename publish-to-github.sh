#!/usr/bin/env bash
# Publish the Agri-Verify demonstration repository, including the actual MP4 video.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
OWNER="houssam-ops"
REPO="agri-verify"
FULL_NAME="$OWNER/$REPO"

if [[ ! -s assets/agri-verify-demo.mp4 ]]; then
  echo "Erreur : la vidéo assets/agri-verify-demo.mp4 est introuvable." >&2
  exit 1
fi
if ! command -v git >/dev/null 2>&1; then
  echo "Git n'est pas installé. Ubuntu : sudo apt install git" >&2
  exit 1
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) n'est pas installé. Ubuntu : sudo apt install gh" >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "Veuillez vous connecter d'abord : gh auth login" >&2
  exit 1
fi
CURRENT_USER="$(gh api user --jq .login)"
if [[ "$CURRENT_USER" != "$OWNER" ]]; then
  echo "Compte GitHub connecté : $CURRENT_USER ; compte attendu : $OWNER" >&2
  echo "Changez de compte avec : gh auth login" >&2
  exit 1
fi

if [[ ! -d .git ]]; then
  git init
fi
if [[ -z "$(git config --get user.name || true)" ]]; then
  git config user.name "Houssam ZOUHEIR"
fi
if [[ -z "$(git config --get user.email || true)" ]]; then
  git config user.email "houssam.zouheir@gmail.com"
fi

git add README.md .gitignore .gitattributes CONTRIBUTING.md SECURITY.md docs assets .github publish-to-github.sh
if ! git diff --cached --quiet; then
  git commit -m "docs: publish Agri-Verify showcase with demo video"
fi
git branch -M main

if gh repo view "$FULL_NAME" >/dev/null 2>&1; then
  echo "Le dépôt $FULL_NAME existe déjà : publication de la branche main."
  if ! git remote get-url origin >/dev/null 2>&1; then
    git remote add origin "https://github.com/$FULL_NAME.git"
  fi
  git push -u origin main
else
  echo "Création du dépôt public $FULL_NAME et envoi des fichiers..."
  gh repo create "$FULL_NAME" --public --description "Satellite-assisted agricultural insurance platform — product demo, parcel mapping, claims and analytics" --source=. --remote=origin --push
fi

echo "Publication terminée : https://github.com/$FULL_NAME"
echo "Vidéo intégrée : https://github.com/$FULL_NAME/blob/main/assets/agri-verify-demo.mp4"

#!/bin/bash
set -e

# Ensure we're in the repo root
cd "$(dirname "$0")"

echo "📦 Building Hugo site..."
hugo -D --source=. --destination=public

# Confirm public exists
if [ ! -d "public" ]; then
  echo "❌ ERROR: Hugo failed to build the site — 'public/' not found."
  exit 1
fi

echo "🧹 Cleaning old site files (except Hugo source)..."
shopt -s extglob
rm -rf !(archetypes|content|layouts|static|themes|public|hugo.toml|deploy.sh|.git|.gitignore|resources)

echo "📁 Copying site build from /public to root..."
cp -r public/. .

echo "🚀 Committing and pushing to GitHub..."
git add .
git commit -m "Deploy site on $(date)"
git push origin main

echo "✅ Site should be live at: https://yogiadi.github.io"

#!/bin/bash
set -e

echo "📦 Building Hugo site..."
hugo -D

echo "🚀 Committing and pushing to GitHub..."
git add .
git commit -m "Deploy site on $(date)"
git push origin main

echo "✅ Live at: https://yogiadi.github.io"

#!/usr/bin/env bash
# Usage: ./deploy.sh <github_username> <repo_name>
# Example: ./deploy.sh johndoe notion-widgets
# Creates repo + pushes + enables GitHub Pages automatically
# Requires: gh CLI authenticated (gh auth login)

set -e

GITHUB_USER=${1:-""}
REPO_NAME=${2:-"notion-widgets"}

if [ -z "$GITHUB_USER" ]; then
  echo "Usage: ./deploy.sh <github_username> [repo_name]"
  exit 1
fi

REPO_URL="https://github.com/$GITHUB_USER/$REPO_NAME"

echo "==> Creating GitHub repo: $REPO_URL"
gh repo create "$REPO_NAME" --public --description "Self-contained Notion embed widgets" 2>/dev/null || echo "(repo may already exist)"

echo "==> Setting remote..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"

echo "==> Renaming branch to main..."
git branch -M main

echo "==> Pushing..."
git push -u origin main

echo "==> Enabling GitHub Pages (deploy from main branch)..."
gh api --method PUT "repos/$GITHUB_USER/$REPO_NAME/pages" \
  -f source[branch]=main \
  -f source[path]="/" 2>/dev/null || echo "(Pages already enabled or use web UI)"

echo ""
echo "===== DONE ====="
echo "Widget base URL: https://$GITHUB_USER.github.io/$REPO_NAME"
echo ""
echo "Add this to E:/PROJECT/notion-forge/.env:"
echo "WIDGET_BASE_URL=https://$GITHUB_USER.github.io/$REPO_NAME"
echo ""
echo "Notion embed examples:"
echo "  Clock:     https://$GITHUB_USER.github.io/$REPO_NAME/clock.html?style=digital"
echo "  Countdown: https://$GITHUB_USER.github.io/$REPO_NAME/countdown.html?to=2026-12-31&label=Year+End"
echo "  Quote:     https://$GITHUB_USER.github.io/$REPO_NAME/quote.html"
echo "  Pomodoro:  https://$GITHUB_USER.github.io/$REPO_NAME/pomodoro.html"
echo "  Habits:    https://$GITHUB_USER.github.io/$REPO_NAME/habit-tracker.html?habits=运动,阅读,冥想"

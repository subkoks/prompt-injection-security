#!/usr/bin/env bash
# git-sync.sh — safe pull-rebase, commit, push over SSH.
#
# Usage:
#   ./scripts/git-sync.sh [commit message]
#
# Behavior:
#   1. Refuses to run mid-rebase/merge or without an origin remote.
#   2. git pull --rebase origin main (aborts cleanly on conflict).
#   3. Stages tracked changes only (git add -u — untracked files are
#      a deliberate, manual decision).
#   4. Commits with the given message, or a timestamp message.
#   5. Plain push to origin main. Never force-pushes.
#
# Exit codes: 0 synced or nothing to do, 1 rebase conflict / push rejected,
#             2 usage or preflight failure.

set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d .git ]; then
  echo "error: not a git repository" >&2
  exit 2
fi
if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] || [ -f .git/MERGE_HEAD ]; then
  echo "error: rebase or merge already in progress — resolve it first" >&2
  exit 2
fi
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "error: no 'origin' remote configured (see PUBLISH_CHECKLIST.md)" >&2
  exit 2
fi

origin_url=$(git remote get-url origin)
case "$origin_url" in
  git@github.com:*) ;;
  *) echo "warning: origin is not an SSH remote: $origin_url" >&2 ;;
esac

echo "pull --rebase origin main"
if ! git pull --rebase origin main; then
  git rebase --abort 2>/dev/null || true
  echo "" >&2
  echo "rebase conflict — aborted, tree left as before the pull." >&2
  echo "Resolve manually: git pull --rebase origin main, fix conflicts," >&2
  echo "git rebase --continue, then re-run this script." >&2
  exit 1
fi

git add -u

if git diff --cached --quiet; then
  ahead=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
  if [ "$ahead" -eq 0 ]; then
    echo "nothing to sync"
    exit 0
  fi
  echo "no new changes to commit; pushing $ahead existing commit(s)"
else
  if [ $# -ge 1 ]; then
    msg="$*"
  else
    msg="sync: $(date '+%Y-%m-%d %H:%M')"
  fi
  git commit -m "$msg"
  echo "committed: $msg"
fi

echo "push origin main"
if ! git push origin main; then
  echo "push rejected — pull and retry; this script never force-pushes" >&2
  exit 1
fi
echo "synced."

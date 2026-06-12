#!/usr/bin/env bash
# git-status.sh — quick read-only repo dashboard.
#
# Usage: ./scripts/git-status.sh
# Always exits 0 (informational only; safe in && chains).

set -euo pipefail

cd "$(dirname "$0")/.."

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
echo "branch:   $branch"

if git remote get-url origin >/dev/null 2>&1; then
  git fetch --quiet origin 2>/dev/null || true
  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    counts=$(git rev-list --left-right --count "origin/main...HEAD" 2>/dev/null || echo "? ?")
    behind=${counts%%[\	 ]*}
    ahead=${counts##*[\	 ]}
    echo "remote:   $(git remote get-url origin)"
    echo "ahead:    $ahead  behind: $behind (vs origin/main)"
  else
    echo "remote:   $(git remote get-url origin) (no origin/main yet — not pushed)"
  fi
else
  echo "remote:   none configured (see docs/internal/PUBLISH_CHECKLIST.md)"
fi

echo "last:     $(git log -1 --oneline 2>/dev/null || echo 'no commits')"

stashes=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
echo "stashes:  $stashes"

dirty=$(git status --short)
if [ -n "$dirty" ]; then
  echo "working tree:"
  printf '%s\n' "$dirty"
else
  echo "working tree: clean"
fi

echo "recent:"
git log --oneline -5 2>/dev/null || true

exit 0

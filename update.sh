#!/usr/bin/env bash
# update.sh — pull the latest version and refresh the local install.
#
# Usage:
#   ./update.sh           pull --rebase, re-link, healthcheck
#   ./update.sh --check   report how far behind origin/main this clone is
#
# Exit codes: 0 ok, 1 dirty tree / failed pull / failed healthcheck, 2 usage.

set -euo pipefail

cd "$(dirname "$0")"

case "${1:-}" in
  --check)
    if ! git remote get-url origin >/dev/null 2>&1; then
      echo "no origin remote configured — nothing to check"
      exit 0
    fi
    git fetch --quiet origin
    behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
    echo "behind origin/main: $behind commit(s)"
    exit 0
    ;;
  "") ;;
  *) echo "usage: $0 [--check]" >&2; exit 2 ;;
esac

if [ -n "$(git status --porcelain)" ]; then
  echo "error: working tree is dirty — commit or stash first" >&2
  echo "(or use ./scripts/git-sync.sh to commit and push your changes)" >&2
  exit 1
fi

if git remote get-url origin >/dev/null 2>&1; then
  echo "pull --rebase origin main"
  git pull --rebase origin main
else
  echo "no origin remote — skipping pull (local-only repo)"
fi

echo "refreshing symlinks"
./install.sh

echo "running healthcheck"
./healthcheck.sh --quick

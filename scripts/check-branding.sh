#!/usr/bin/env bash
# check-branding.sh — fail if stale upstream branding exists outside the
# allowed locations. Used by CI, the pre-commit hook, and healthcheck.sh.
#
# Allowed: LICENSE (attribution lives there), this script (the regex below),
# BLACKTERMINAL_MIGRATION_PLAN.md (the audit necessarily names upstream),
# tests/fixtures (defense in depth), and the single canonical attribution
# sentence — in README.md and CHANGELOG.md only.
#
# Exit codes: 0 clean, 1 stale branding found.

set -euo pipefail

cd "$(dirname "$0")/.."

# Attribution sentence is only allowed in README.md and CHANGELOG.md.
ALLOWED_LINE='^\./(README|CHANGELOG)\.md:.*[Pp]ortions( of this project are)? derived from BridgeWard'

hits=$(grep -rniE 'bridgemind|bridge-mind|bridgeward' . \
  --exclude-dir=.git \
  --exclude-dir=fixtures \
  --exclude=LICENSE \
  --exclude=check-branding.sh \
  --exclude=BLACKTERMINAL_MIGRATION_PLAN.md \
  | grep -vE "$ALLOWED_LINE" || true)

if [ -n "$hits" ]; then
  printf '%s\n' "$hits"
  echo "FAIL: stale upstream branding found"
  exit 1
fi
echo "OK: no stale upstream branding"

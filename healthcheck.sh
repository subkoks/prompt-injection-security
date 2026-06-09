#!/usr/bin/env bash
# healthcheck.sh — verify this repo and its local install are intact.
#
# Usage:
#   ./healthcheck.sh           full check (includes scanner smoke test)
#   ./healthcheck.sh --quick   skip the scanner smoke test
#
# Exit codes: 0 all checks pass, 1 one or more failures.

set -euo pipefail

cd "$(dirname "$0")"

QUICK=0
[ "${1:-}" = "--quick" ] && QUICK=1

FAILURES=0
pass() { echo "PASS  $*"; }
fail() { echo "FAIL  $*"; FAILURES=$((FAILURES+1)); }
note() { echo "note  $*"; }

# 1. required tools
for t in git perl grep; do
  if command -v "$t" >/dev/null 2>&1; then
    pass "tool: $t"
  else
    fail "tool missing: $t"
  fi
done
note "bash version: ${BASH_VERSION:-unknown} (3.2 is supported)"

# 2. file inventory
for f in \
  .claude-plugin/plugin.json \
  skills/prompt-injection-security/SKILL.md \
  skills/prompt-injection-security/references/threat-taxonomy.md \
  skills/prompt-injection-security/references/red-flag-patterns.md \
  skills/prompt-injection-security/references/case-studies.md \
  skills/prompt-injection-security/references/trust-labels.md \
  skills/prompt-injection-security/references/per-tool-defenses.md \
  skills/prompt-injection-security/references/refusal-templates.md \
  skills/prompt-injection-security/references/checklist.md \
  skills/injection-audit/SKILL.md \
  agents/injection-auditor.md \
  scripts/scan.sh \
  scripts/check-branding.sh \
  tests/run-tests.sh \
  LICENSE README.md CHANGELOG.md; do
  if [ -e "$f" ]; then
    pass "file: $f"
  else
    fail "file missing: $f"
  fi
done

# 3. version consistency
WANT_VERSION="0.1.0"
ver_ok=1
if ! grep -q "\"version\": \"$WANT_VERSION\"" .claude-plugin/plugin.json 2>/dev/null; then ver_ok=0; fi
for sk in skills/prompt-injection-security/SKILL.md skills/injection-audit/SKILL.md; do
  if ! grep -q "version: \"$WANT_VERSION\"" "$sk" 2>/dev/null; then ver_ok=0; fi
done
if ! grep -q "$WANT_VERSION" CHANGELOG.md 2>/dev/null; then ver_ok=0; fi
if [ "$ver_ok" -eq 1 ]; then
  pass "version $WANT_VERSION consistent (plugin.json, SKILL.md x2, CHANGELOG)"
else
  fail "version mismatch — expected $WANT_VERSION everywhere"
fi

# 4. symlink integrity (skip if install.sh has not been run / editor absent)
REPO="$(pwd)"
check_link() { # check_link <linkpath>
  local lp="$1" resolved
  if [ ! -e "$lp" ]; then
    note "not installed: $lp (run ./install.sh)"
    return
  fi
  if [ ! -L "$lp" ]; then
    fail "exists but is not a symlink: $lp"
    return
  fi
  resolved="$(cd -P "$(dirname "$lp")" && cd -P "$(readlink "$lp")" 2>/dev/null && pwd || true)"
  case "$resolved" in
    "$REPO"*|"$HOME/.cursor/skills"*) pass "link: $lp" ;;
    *) fail "link resolves outside this repo: $lp -> $resolved" ;;
  esac
}
for s in prompt-injection-security injection-audit; do
  [ -d "$HOME/.cursor" ]  && check_link "$HOME/.cursor/skills/$s"
  [ -d "$HOME/.claude" ]  && check_link "$HOME/.claude/skills/$s"
done
if [ -d "$HOME/.claude" ]; then
  lp="$HOME/.claude/agents/injection-auditor.md"
  if [ -L "$lp" ]; then pass "link: $lp"; elif [ -e "$lp" ]; then fail "exists but is not a symlink: $lp"; else note "not installed: $lp"; fi
fi

# 5. scanner smoke test
if [ "$QUICK" -eq 1 ]; then
  note "scanner smoke test skipped (--quick)"
else
  if ./scripts/scan.sh tests/fixtures/clean >/dev/null 2>&1; then
    pass "scan.sh: clean fixtures -> exit 0"
  else
    fail "scan.sh: clean fixtures should exit 0"
  fi
  if ./scripts/scan.sh tests/fixtures/dirty >/dev/null 2>&1; then
    fail "scan.sh: dirty fixtures should exit 1"
  else
    pass "scan.sh: dirty fixtures -> exit 1"
  fi
fi

# 6. branding gate
if ./scripts/check-branding.sh >/dev/null 2>&1; then
  pass "branding gate clean"
else
  fail "branding gate found stale upstream branding"
fi

# 7. shellcheck (optional locally; CI runs it always)
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck install.sh update.sh healthcheck.sh scripts/*.sh tests/run-tests.sh hooks/pre-commit >/dev/null 2>&1; then
    pass "shellcheck clean"
  else
    fail "shellcheck reported issues"
  fi
else
  note "shellcheck not installed locally (CI covers it)"
fi

echo "---"
if [ "$FAILURES" -gt 0 ]; then
  echo "healthcheck: $FAILURES failure(s)"
  exit 1
fi
echo "healthcheck: all checks passed"

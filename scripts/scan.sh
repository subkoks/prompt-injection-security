#!/usr/bin/env bash
# prompt-injection-security/scripts/scan.sh
#
# Quick offline scan for the most common prompt-injection patterns.
# Not a substitute for the full injection-auditor subagent, but useful
# in CI / pre-commit hooks to catch low-hanging fruit fast.
#
# Portable to macOS system bash 3.2 (no bash-4-only builtins).
#
# Usage:
#   ./scan.sh <file-or-directory>
#   ./scan.sh ./cloned-repo
#
# Exit codes:
#   0 — clean
#   1 — findings detected
#   2 — usage error

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <file-or-directory>" >&2
  exit 2
fi

TARGET="$1"
if [ ! -e "$TARGET" ]; then
  echo "error: target does not exist: $TARGET" >&2
  exit 2
fi

FINDINGS=0
SCANNED=0
RED='\033[0;31m'
YEL='\033[0;33m'
NC='\033[0m'

flag() {
  local sev="$1"; shift
  local msg="$*"
  if [ "$sev" = "HIGH" ]; then
    printf '%b[HIGH]%b %s\n' "$RED" "$NC" "$msg"
  else
    printf '%b[%s]%b %s\n' "$YEL" "$sev" "$NC" "$msg"
  fi
  FINDINGS=$((FINDINGS+1))
}

# Files to scan (markdown, config, code-ish)
FILE_GLOBS=(
  '*.md'
  '*.txt'
  '*.html'
  '*.htm'
  '*.json'
  '*.yaml'
  '*.yml'
  '*.toml'
  '*.cursorrules'
  '*.windsurfrules'
  '*.continuerules'
  '*.clinerules'
  '.aider.conf.yml'
  '.mcp.json'
  'Makefile'
  'package.json'
)

scan_file() {
  local f="$1"
  SCANNED=$((SCANNED+1))

  # 1. Imperative-override phrases
  if grep -inE 'ignore (all |the )?(previous|prior|above|earlier) (instructions?|prompts?|rules?)' "$f" >/dev/null 2>&1; then
    flag MED "$f: imperative-override phrase"
  fi
  if grep -inE 'you are now (DAN|jailbroken|in developer mode|unrestricted)' "$f" >/dev/null 2>&1; then
    flag MED "$f: role-coercion phrase (DAN / developer mode)"
  fi
  if grep -inE 'the user (has )?(authorized|approved|consented|permitted)' "$f" >/dev/null 2>&1; then
    flag MED "$f: authority impersonation"
  fi

  # 2. Fake chat-format tokens
  if grep -nE '<\|im_start\|>|<\|im_end\|>|<<SYS>>|\[INST\]' "$f" >/dev/null 2>&1; then
    flag MED "$f: fake chat-format tokens"
  fi

  # 3. Hidden Unicode (zero-width + tag block)
  if perl -CSDA -ne 'exit 1 if /[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{2060}]/' "$f" 2>/dev/null; then :; else
    flag HIGH "$f: zero-width characters present"
  fi
  if perl -CSDA -ne 'exit 1 if /[\x{E0000}-\x{E007F}]/' "$f" 2>/dev/null; then :; else
    flag HIGH "$f: Unicode tag block (ASCII smuggling) present"
  fi

  # 4. Hidden CSS
  if grep -inE 'style\s*=\s*"[^"]*\b(display\s*:\s*none|visibility\s*:\s*hidden|font-size\s*:\s*0|color\s*:\s*(white|#fff))' "$f" >/dev/null 2>&1; then
    flag HIGH "$f: hidden CSS (display:none / color:white / font-size:0)"
  fi

  # 5. HTML comments containing imperatives
  if grep -inE '<!--[^>]*?(ignore|system|instruction|fetch|run|execute)[^>]*?-->' "$f" >/dev/null 2>&1; then
    flag HIGH "$f: HTML comment with imperative content"
  fi

  # 6. Markdown image with data param (exfil)
  if grep -inE '!\[[^]]*\]\(\s*https?://[^/)]*\?[^)]*\b(data|content|file|env|secret|key|token)=' "$f" >/dev/null 2>&1; then
    flag HIGH "$f: markdown image with data-exfil URL"
  fi

  # 7. CSV / spreadsheet formula injection
  if grep -inE '=(HYPERLINK|IMPORTDATA|IMPORTXML|WEBSERVICE|IMPORTHTML|IMPORTRANGE)\(' "$f" >/dev/null 2>&1; then
    flag HIGH "$f: spreadsheet formula injection construct"
  fi

  # 8. SSRF / private-network URLs
  if grep -inE 'https?://(127\.|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|169\.254\.169\.254|metadata\.google\.internal)' "$f" >/dev/null 2>&1; then
    flag MED "$f: private-network / metadata URL"
  fi

  # 9. Curl|sh install pattern
  if grep -inE 'curl[^|]+\|\s*(sudo\s+)?(bash|sh|zsh)' "$f" >/dev/null 2>&1; then
    flag HIGH "$f: curl|sh remote-code-execution pattern"
  fi
  if grep -inE 'wget[^|]+\|\s*(sudo\s+)?(bash|sh|zsh)' "$f" >/dev/null 2>&1; then
    flag HIGH "$f: wget|sh remote-code-execution pattern"
  fi

  # 10. package.json postinstall
  case "$f" in
    *package.json)
      if grep -nE '"(pre|post)install"\s*:' "$f" >/dev/null 2>&1; then
        flag MED "$f: pre/post-install hook (review before npm install)"
      fi
      ;;
  esac
}

echo "prompt-injection-security quick-scan"
echo "Target: $TARGET"
echo "---"

if [ -f "$TARGET" ]; then
  scan_file "$TARGET"
else
  FIND_ARGS=("$TARGET" -type f -not -path '*/.git/*' -not -path '*/node_modules/*')
  FIND_ARGS+=(\()
  first=1
  for g in "${FILE_GLOBS[@]}"; do
    if [ "$first" -eq 1 ]; then
      FIND_ARGS+=(-name "$g")
      first=0
    else
      FIND_ARGS+=(-o -name "$g")
    fi
  done
  FIND_ARGS+=(\))
  # -print0 / read -d '': filenames with newlines must not evade the scan
  while IFS= read -r -d '' f; do
    scan_file "$f"
  done < <(find "${FIND_ARGS[@]}" -print0 2>/dev/null)
fi

echo "---"
echo "Files scanned: $SCANNED"
if [ "$FINDINGS" -eq 0 ]; then
  echo "No findings."
  exit 0
else
  echo "Total findings: $FINDINGS"
  echo ""
  echo "Run the full /injection-audit slash-command for a deeper review,"
  echo "or invoke the injection-auditor subagent for line-by-line analysis."
  exit 1
fi

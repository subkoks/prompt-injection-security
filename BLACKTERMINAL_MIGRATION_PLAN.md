# Migration Plan: BridgeWard -> prompt-injection-security

Phase-1 audit artifact for the blackterminal derivative. This file is the
record of what was ported, rewritten, fixed, and dropped. It necessarily
names the upstream project throughout and is therefore excluded from
`scripts/check-branding.sh`.

## Source

- Upstream: `bridge-mind/BridgeWard` (GitHub), MIT, copyright (c) 2026
  BridgeMind. 53 KB, Shell + Markdown. Audited at depth-1 clone, 2026-06-09.
- License obligation: preserve the MIT copyright notice for derived
  portions. Satisfied by the attribution in `NOTICE` and the canonical
  attribution sentence in `README.md` and `CHANGELOG.md`.

## Audit results

- **Hidden Unicode**: none in any upstream file (verified by perl scan over
  every tracked file). All hidden-character material in the reference docs
  uses escaped `U+XXXX` notation — safe to port as text.
- **Brand density** (lines matching `bridgemind|bridgeward|bridge-mind`,
  case-insensitive): README.md 25, CONTRIBUTING.md 5, plugin.json 4,
  agents/injection-auditor.md 3, core SKILL.md 3, trust-labels.md 3,
  CHANGELOG.md 2, scan.sh 2, checklist.md 2, injection-audit SKILL.md 2,
  LICENSE 1, threat-taxonomy.md 1; case-studies.md, red-flag-patterns.md,
  per-tool-defenses.md, refusal-templates.md, .gitignore 0.
- **Upstream bug found**: `scripts/scan.sh` zero-width and tag-block checks
  could never fire — `perl -ne 'exit 0 if /match/'` exits 0 with or without
  a match, so the failure branch that raises the flag was unreachable.
- **Portability bug**: upstream `scan.sh` uses `mapfile`, which does not
  exist in macOS system bash 3.2 — the script cannot run on stock macOS.

## Port strategy (as executed)

| Upstream | Here | Strategy |
|---|---|---|
| `skills/bridgeward/SKILL.md` | `skills/prompt-injection-security/SKILL.md` | Renamed; frontmatter rewritten (name, author blackterminal, version 0.1.0, original description with the same activation-trigger nouns); framing paragraph rewritten; technical doctrine ported intact |
| `skills/bridgeward/references/*` (7 files) | `skills/prompt-injection-security/references/*` | Copied; brand mentions swept (6 lines across 3 files); escaped `U+XXXX` tables preserved byte-exact |
| `skills/injection-audit/SKILL.md` | same path | Copied; author/version/report-title swept |
| `agents/injection-auditor.md` | same path | Copied; skills list updated to renamed skill; brand swept; emoji markers replaced with Bad:/Good: |
| `scripts/scan.sh` | same path | Rewritten for bash 3.2 (`while read` + inline find args instead of `mapfile`); hidden-Unicode detection fixed (`exit 1 if /match/`); detection regexes preserved; banner rebranded; exit contract 0/1/2 kept |
| `.claude-plugin/plugin.json` | same path | Rewritten: new name/author/homepage/description, version 0.1.0, blackterminal tag |
| `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `LICENSE` | — | Rewritten from scratch (attribution preserved per MIT) |
| `.gitignore` | — | Replaced with blackterminal-security's |
| Discord badge, bridgemind.ai links, "Trust nothing. Ship safely." tagline | — | Dropped, no replacement |

## Net-new (no upstream equivalent)

`install.sh` / `update.sh` / `healthcheck.sh` (symlink wiring for Claude
Code, Cursor, Windsurf), `scripts/check-branding.sh`,
`scripts/git-sync.sh`, `scripts/git-status.sh`, `hooks/pre-commit`,
`tests/` (14-case harness + fixtures; upstream had no tests),
`.github/` (CI with shellcheck + bash-3.2 guard + branding and
hidden-Unicode gates, templates, CODEOWNERS), `docs/usage.md`, `examples/`,
`CLAUDE.md`, `SECURITY.md`, `LOCAL_SETUP.md`, `PUBLISH_CHECKLIST.md`,
`.editorconfig`.

## Risk register

- Reference docs and `tests/fixtures/dirty/` contain injection-pattern text
  by design — never scan the repo wholesale; CI never does.
- Literal hidden Unicode is banned from the tree (CI gate); invisible test
  payloads are generated at runtime.
- The branding gate allows upstream names only in `NOTICE`, this file, the
  gate script itself, and the canonical attribution sentence.

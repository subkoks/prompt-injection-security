# prompt-injection-security — project instructions

Prompt-injection defense for AI agent workflows, by blackterminal. This repo
packages a skeptical-reading discipline (auto-loaded skill), an on-demand
audit command, a read-only auditor subagent, and an offline scanner, and
symlinks them into every AI editor on the machine (Claude Code, Cursor,
Windsurf) so one `git pull` updates them all.

Brand: blackterminal. Author: Ingus Liepins (black.terminal), GitHub
`subkoks`. Primary use case: defending agents that read untrusted content —
web pages, GitHub issues, MCP tool descriptions, third-party repos.

## Key files

| Path | Role |
|---|---|
| `skills/prompt-injection-security/SKILL.md` | Core discipline; frontmatter description controls auto-activation |
| `skills/prompt-injection-security/references/` | Seven reference docs (taxonomy, patterns, case studies, labels, defenses, templates, checklist) |
| `skills/injection-audit/SKILL.md` | `/injection-audit` slash command (forks into the auditor agent) |
| `agents/injection-auditor.md` | Read-only auditor subagent |
| `scripts/scan.sh` | Offline scanner; exit 0 clean / 1 findings / 2 usage |
| `scripts/check-branding.sh` | Gate: upstream brand names allowed only in NOTICE, the meta-docs (migration plan, handoff), the gate script itself, and the canonical attribution sentence in README/CHANGELOG |
| `install.sh` / `update.sh` / `healthcheck.sh` | Symlink install, update, verify |
| `tests/run-tests.sh` + `tests/fixtures/` | Scanner test suite |
| `.claude-plugin/plugin.json` | Plugin manifest — `skills`/`agents` paths must match directory names exactly |

## Run, test, update

```bash
./tests/run-tests.sh        # full scanner suite (run under /bin/bash to prove bash 3.2)
./healthcheck.sh            # files, versions, symlinks, scanner smoke, branding gate
./scripts/scan.sh <path>    # ad hoc scan
./install.sh --dry-run      # preview editor wiring
./update.sh                 # pull --rebase + re-link + healthcheck
./scripts/git-sync.sh [msg] # safe commit + push (never force)
```

## Rules for this project

- **SSH only.** Git remotes use `git@github.com:...`; never HTTPS.
- **No upstream brand names** (the project this derives from) anywhere
  except `NOTICE`, the meta-docs (`docs/internal/BLACKTERMINAL_MIGRATION_PLAN.md`,
  `docs/internal/FINAL_HANDOFF.md`), the gate script itself, and the one canonical
  attribution sentence in README/CHANGELOG. `./scripts/check-branding.sh`
  enforces exactly that allowlist — run it after editing docs.
- **blackterminal voice**: technical, direct, no fluff, no emoji, no
  marketing copy.
- **Target environment**: macOS first. All shell must run on system bash
  3.2 — no `mapfile`, `readarray`, `declare -A`. CI has a static guard, but
  verify locally with `/bin/bash`.
- **Never commit literal hidden Unicode** (zero-width / tag-block).
  Hidden-character examples use escaped `U+XXXX` notation; invisible test
  payloads are generated at runtime by `tests/run-tests.sh`.
- **Never scan this repo wholesale** with `scan.sh` or `/injection-audit` —
  `skills/prompt-injection-security/references/` and `tests/fixtures/dirty/`
  intentionally contain detection patterns. Scope self-audits to `scripts/`,
  root docs, and `.github/`.
- Version `0.1.0` must stay consistent across `plugin.json`, both
  `SKILL.md` files, and `CHANGELOG.md` (healthcheck verifies).
- One logical change per commit, `type(scope): description`, imperative.
- Pushing, repo creation, and visibility changes require explicit user
  approval (see docs/internal/PUBLISH_CHECKLIST.md).
## Cloud sessions (Claude Code on the web)

This repo is cloud-ready. A `SessionStart` hook (`.claude/settings.json` -> `scripts/cloud-setup.sh`) bootstraps dependencies automatically in Anthropic cloud sessions (`claude --remote`, `claude.ai/code`). It is cloud-guarded (`CLAUDE_CODE_REMOTE=true`) and a no-op in local sessions.

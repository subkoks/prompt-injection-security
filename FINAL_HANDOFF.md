# Final Handoff

`prompt-injection-security` — blackterminal prompt-injection defense plugin,
derived from the MIT-licensed BridgeWard. Built locally; not yet pushed.

## Status

- Local repo: `~/Projects/prompt-injection-security`, branch `main`, working
  tree clean, 12 commits.
- Remote: **none configured.** Creation and first push are approval-gated —
  see `PUBLISH_CHECKLIST.md`.
- Installed locally: skills and agent are symlinked into Claude Code, Cursor,
  Windsurf, and the agents mirror. `./healthcheck.sh` passes.

## What was built

- **Core skill** `skills/prompt-injection-security/` — skeptical-reading
  discipline + 7 reference documents, auto-activates on untrusted content.
- **`injection-audit` skill** + **`injection-auditor` agent** — on-demand
  audits via a read-only subagent (mutation tools withheld, shell limited to
  inspection).
- **`scripts/scan.sh`** — offline scanner, portable to macOS system bash 3.2,
  with working hidden-Unicode detection and resistance to hostile filenames.
- **Ops** — `install.sh` / `update.sh` / `healthcheck.sh`,
  `scripts/{check-branding,git-sync,git-status}.sh`, `hooks/pre-commit`.
- **Tests** — `tests/run-tests.sh`, 20 cases, one per scanner check plus
  hostile-filename and runtime-generated hidden-Unicode cases. All green
  under `/bin/bash` (3.2.57).
- **CI** — shellcheck, bash-3.2 portability guard, scanner tests, branding
  gate, hidden-Unicode gate. Triggers exclude `pull_request_target`.
- **Docs** — README (10-section spec), `docs/usage.md`, `examples/`,
  CONTRIBUTING, SECURITY, CHANGELOG, CLAUDE.md, LOCAL_SETUP.md,
  PUBLISH_CHECKLIST.md, BLACKTERMINAL_MIGRATION_PLAN.md.

## Verification (all passing locally)

| Check | Result |
|---|---|
| `./scripts/check-branding.sh` | no stale upstream branding |
| hidden-Unicode scan over tracked files | none |
| bash >3.2 construct guard | none |
| `/bin/bash tests/run-tests.sh` | 20/20 |
| `shellcheck` (all scripts) | clean |
| `./healthcheck.sh` | all checks passed |
| `plugin.json` paths | valid, version 0.1.0 |
| `ssh -T git@github.com` | authenticated as subkoks |

A two-pass adversarial multi-agent review (4 dimensions: shell, branding,
docs, security) raised 14 findings; all were fixed or verified-benign. Fixes
landed in commits `1fe5bb3` and `ef8c94e`: scanner hostile-filename
resistance, `--uninstall` symlink-ownership check, git-sync main-branch and
no-remote guards, CI option-injection hardening, real Claude Code tool names
in the agent, corrected capability/fixture-coverage claims, and tightened
branding-gate scoping.

## Deliberately preserved (license obligation)

- `LICENSE` carries both copyright lines: `Ingus Liepins (black.terminal)`
  and `Portions derived from BridgeWard, Copyright (c) 2026 BridgeMind`.
- One canonical attribution sentence appears in `README.md` and
  `CHANGELOG.md`. The branding gate allows that sentence **only** in those
  two files; upstream names otherwise appear only in `LICENSE`, this handoff,
  the migration plan, and the gate script itself.
- The skill reference-document bodies are intentionally ported (and licensed);
  branding was swept from them. `BLACKTERMINAL_MIGRATION_PLAN.md` records the
  full port-vs-rewrite decision per file.

## Legal / license notes

MIT-to-MIT derivative. Attribution requirements are satisfied by the LICENSE
copyright lines plus the canonical sentence. No upstream trademark, logo, or
marketing copy was carried over. All brand copy is original.

## Manual steps still requiring your approval

1. **Create the private repo and push** — run `PUBLISH_CHECKLIST.md` after you
   approve. Nothing remote has happened yet.
2. **Optional global git config** — the `url.insteadOf` SSH-rewrite block in
   `LOCAL_SETUP.md` is documented, not applied.

## Recommended next actions

- Approve and run `PUBLISH_CHECKLIST.md`; confirm CI goes green on the first
  push and that visibility reads `PRIVATE`.
- After pushing, `./install.sh --with-hooks` if you want the branding +
  syntax pre-commit hook active in this clone.
- Future pattern or case-study additions: follow `CONTRIBUTING.md` (citation
  required; scanner changes need a fixture).

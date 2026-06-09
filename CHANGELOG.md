# Changelog

All notable changes to prompt-injection-security.

## [0.1.0] — 2026-06-09

### Initial release

- `prompt-injection-security` skill — skeptical-reading discipline
  auto-loaded for any agent ingesting untrusted content, with seven reference
  documents: threat taxonomy, red-flag pattern catalog, case studies, trust
  labels, per-tool defenses, refusal templates, and the 10-question checklist
- `injection-audit` skill — slash-command audit for files, directories, URLs,
  and MCP servers
- `injection-auditor` agent — read-only auditor subagent
- `scripts/scan.sh` — offline scanner, portable to macOS system bash 3.2,
  with working zero-width and Unicode tag-block detection
- Test harness with committed fixtures per detection category and
  runtime-generated hidden-Unicode cases (`tests/run-tests.sh`)
- Symlink installer for Claude Code, Cursor, and Windsurf (`install.sh`),
  plus `update.sh`, `healthcheck.sh`, and git helper scripts
- CI: shellcheck, bash 3.2 portability guard, scanner tests, branding gate,
  hidden-Unicode gate
- Plugin manifest (`.claude-plugin/plugin.json`)

### Attribution

Portions of this project are derived from BridgeWard, copyright (c) 2026 BridgeMind, used under the MIT License.

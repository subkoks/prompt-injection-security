# Changelog

All notable changes to prompt-injection-security.

## [0.1.0] — 2026-06-09

### Initial release

- `prompt-injection-security` skill — the blackterminal skeptical-reading
  discipline, activated automatically when an agent reads untrusted content;
  ships seven reference documents (threat taxonomy, red-flag patterns, case
  studies, trust labels, per-tool defenses, refusal templates, checklist)
- `injection-audit` skill — on-demand audit command covering file, directory,
  URL, and MCP-server targets
- `injection-auditor` agent — deep-audit subagent with mutation tools
  withheld and shell limited to inspection
- `scripts/scan.sh` — offline scanner, portable to macOS system bash 3.2,
  with working zero-width and Unicode tag-block detection
- Test coverage for every scanner check (`tests/run-tests.sh`): committed
  fixtures for visible patterns, runtime-generated cases for invisible
  Unicode payloads and hostile filenames
- Symlink installer for Claude Code, Cursor, and Windsurf (`install.sh`),
  plus `update.sh`, `healthcheck.sh`, and git helper scripts
- CI: shellcheck, bash 3.2 portability guard, scanner tests, branding gate,
  hidden-Unicode gate
- Plugin manifest (`.claude-plugin/plugin.json`)

### Attribution

Portions of this project are derived from BridgeWard, copyright (c) 2026 BridgeMind, used under the MIT License.

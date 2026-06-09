# prompt-injection-security

[![CI](https://github.com/subkoks/prompt-injection-security/actions/workflows/ci.yml/badge.svg)](https://github.com/subkoks/prompt-injection-security/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](#installation)

Prompt-injection defense for AI agent workflows: a skeptical-reading
discipline your agents load automatically, an on-demand audit command, a
read-only auditor subagent, and an offline scanner for CI and pre-commit. A
blackterminal project.

## Why this exists

Every agent in my workflow reads content somebody else wrote: web pages,
GitHub issues, MCP tool descriptions, third-party repos, search results,
scraped HTML. Each of those is a channel through which an attacker can hand
the agent instructions — and an agent with file access, shell access, and
network access will follow them unless it has been trained not to.

The vendor-side fixes are incomplete by their own admission, and the public
CVE record (zero-click email exfiltration, rug-pulled MCP tools, invisible
directives in editor rules files, injection-to-RCE chains in coding agents)
shows the gap is being exploited in production. What an operator can control
is the discipline the agent runs under. This repo packages that discipline so
every editor and agent on the machine inherits it from one place.

## Features

- **`prompt-injection-security` skill** — core skeptical-reading discipline,
  auto-activated whenever an agent ingests untrusted content. Provenance
  trust labels, the Lethal Trifecta model, five core rules, red-flag pattern
  catalog, per-tool defense rules, refusal templates, and a 10-question
  checklist. Seven reference documents load on demand.
- **`injection-audit` skill** — slash command. Point it at a file, directory,
  URL, or MCP server and get a severity-ranked report of injection attempts,
  with hidden characters made visible and concrete remediation per finding.
- **`injection-auditor` agent** — read-only subagent that performs the deep
  audits. Cannot write, edit, or execute; cannot follow instructions found in
  the content it scans.
- **`scripts/scan.sh`** — offline grep/perl scanner for the most common
  patterns (override phrases, fake chat tokens, zero-width and tag-block
  Unicode, hidden CSS, exfil URLs, formula injection, SSRF, curl-pipe-shell,
  postinstall hooks). Exit-code contract for CI and hooks. Runs on stock
  macOS bash 3.2.
- **Symlink installer** — one repo wires Claude Code, Cursor, and Windsurf at
  once; `git pull` updates every editor.

## Installation

macOS, SSH-first:

```bash
git clone git@github.com:subkoks/prompt-injection-security.git
cd prompt-injection-security
./install.sh
```

The installer symlinks the skills and agent into every editor it detects
(`~/.claude`, `~/.cursor`, `~/.codeium/windsurf`, `~/.agents`). The repo
stays the single source of truth — no copies, no drift.

```bash
./install.sh --dry-run      # print actions without changing anything
./install.sh --with-hooks   # also install this repo's pre-commit hook
./install.sh --uninstall    # remove the symlinks it created
./healthcheck.sh            # verify files, versions, symlinks, scanner
```

Linux works the same way for any editor that reads `~/.claude/skills`; the
scanner and tests need only bash 3.2+, grep, and perl.

## Usage

### Claude Code

The core skill activates on its own when the agent reads untrusted content —
no invocation needed. Audits are explicit:

```
/injection-audit ./some-cloned-repo
/injection-audit https://suspicious-site.example.com/post
/injection-audit <paste content>
```

The audit runs in the read-only `injection-auditor` subagent and returns a
report with severity counts, verbatim snippets (hidden characters revealed),
and per-finding remediation.

### Terminal

```bash
./scripts/scan.sh <file-or-directory>
```

Exit codes: `0` clean, `1` findings, `2` usage error. Wire it into CI or a
pre-commit hook to catch low-hanging fruit before an agent ever reads the
content. It is a fast first pass, not a replacement for the full audit.

## Configuration

There is no config file; behavior is defined by the skill documents.

- Detection patterns: `skills/prompt-injection-security/references/red-flag-patterns.md`
  (agent-side) and the checks in `scripts/scan.sh` (offline). Add new
  patterns in both places when they are mechanically detectable.
- Trust labels and per-tool rules:
  `skills/prompt-injection-security/references/trust-labels.md` and
  `per-tool-defenses.md`.
- Scanner file coverage: the `FILE_GLOBS` array at the top of
  `scripts/scan.sh`.
- Auditor behavior (severity scoring, false-positive calibration, report
  shape): `agents/injection-auditor.md`.

After editing, run `./tests/run-tests.sh` and `./healthcheck.sh`.

## Examples

Worked examples live in [`examples/`](examples/):

- [`audit-a-repo.md`](examples/audit-a-repo.md) — vetting a freshly cloned
  third-party repo before letting an agent read it
- [`sample-report.md`](examples/sample-report.md) — what an audit report
  looks like and how to act on each severity

Deeper usage notes: [`docs/usage.md`](docs/usage.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). New red-flag patterns and case
studies need a citation (CVE, writeup, paper, or PoC); scanner changes need a
fixture. The repo's own docs intentionally contain injection-pattern text —
read [`tests/fixtures/README.md`](tests/fixtures/README.md) before running
any repo-wide content scan.

## License

MIT — see [LICENSE](LICENSE).

Portions of this project are derived from BridgeWard, copyright (c) 2026 BridgeMind, used under the MIT License.
All other content copyright (c) 2026 Ingus Liepins (black.terminal).

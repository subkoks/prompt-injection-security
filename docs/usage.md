# Usage

## The three layers

| Layer | When it runs | What it does |
|---|---|---|
| `prompt-injection-security` skill | Automatically, whenever the agent ingests untrusted content | Installs the skeptical-reading discipline: trust labels, DATA-not-COMMANDS, plan-before-read, justification tracing, surface-never-comply |
| `/injection-audit` command | On demand | Deep audit of a file, directory, URL, pasted content, or MCP server; runs in the read-only `injection-auditor` subagent |
| `scripts/scan.sh` | In CI, pre-commit hooks, or ad hoc | Fast offline pattern scan with a stable exit-code contract |

## Skill activation

After `./install.sh`, the core skill activates on its own when an agent
reads externally-sourced content: fetched URLs, search results, GitHub
issues/PRs/diffs, MCP tool descriptions and outputs, RAG retrievals, files in
third-party repos, scraped HTML. There is nothing to invoke. You will notice
it when the agent flags an injection attempt instead of acting on it: it
quotes the snippet, names the technique, refuses the embedded action, and
continues with your original task.

## /injection-audit flows

```
/injection-audit ./cloned-third-party-repo
/injection-audit ./README.md
/injection-audit https://suspicious-site.example.com/post
/injection-audit <mcp-server-name>
```

With no argument it audits the most recently fetched or cloned content in
the session, or asks for a target.

The auditor prioritizes known instruction surfaces in directories:
`*.md`, `.cursorrules`, `.windsurfrules`, `CLAUDE.md`, `AGENTS.md`,
`.mcp.json`, `package.json` scripts, `Makefile`, `.vscode/tasks.json`,
`.devcontainer/`. The report format and severity definitions are specified
in `skills/injection-audit/SKILL.md`; an example report is in
[`examples/sample-report.md`](../examples/sample-report.md).

## scan.sh in CI and hooks

```bash
./scripts/scan.sh <file-or-directory>
# 0 = clean, 1 = findings, 2 = usage error
```

Pre-commit example for another repo (scan staged docs before committing):

```bash
#!/usr/bin/env bash
set -euo pipefail
files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(md|txt|html|json|ya?ml)$' || true)
[ -z "$files" ] && exit 0
fail=0
for f in $files; do
  /path/to/prompt-injection-security/scripts/scan.sh "$f" || fail=1
done
exit $fail
```

GitHub Actions step:

```yaml
- name: injection scan on incoming content
  run: /path/to/scan.sh ./content-to-vet
```

## Interpreting scanner findings

- `HIGH` — hidden payloads (zero-width / tag-block Unicode, hidden CSS,
  imperative HTML comments), exfil constructs, formula injection,
  curl-pipe-shell. Treat as hostile until manually reviewed.
- `MED` — visible override phrases, fake chat tokens, authority
  impersonation, private-network URLs, postinstall hooks. Often legitimate in
  context (a security blog quoting an attack is not an attack) — review
  before acting.

The scanner trades depth for speed and has no context awareness. For
anything that matters, follow up with `/injection-audit`, which scores
severity in context and shows hidden characters explicitly.

## Auditing this repo itself

`skills/prompt-injection-security/references/` and `tests/fixtures/dirty/`
intentionally contain the patterns the tooling detects. A repo-wide
`scan.sh .` or `/injection-audit .` here will report findings by design.
Scope self-audits to `scripts/`, root docs, and `.github/`.

## Updating

```bash
./update.sh --check   # how far behind origin/main
./update.sh           # pull --rebase, refresh symlinks, healthcheck
```

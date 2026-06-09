# Example: vet a third-party repo before letting an agent read it

Scenario: you found a tool on GitHub and want Claude Code to help you
evaluate or integrate it. Before any agent ingests the repo, vet it — editor
rules files and install scripts are the classic poisoning surfaces.

## 1. Clone without opening it in an AI editor

```bash
git clone --depth 1 git@github.com:someone/some-tool.git /tmp/vet/some-tool
```

Do not open the folder in Claude Code, Cursor, or Windsurf yet; some
harnesses auto-load `.cursorrules` / `CLAUDE.md` / `AGENTS.md` on open.

## 2. Fast offline pass

```bash
./scripts/scan.sh /tmp/vet/some-tool
echo $?
```

Exit `0` means no low-hanging fruit; it does not mean safe. Exit `1` —
read the findings before going further.

## 3. Deep audit from a session that has the skills installed

```
/injection-audit /tmp/vet/some-tool
```

The read-only auditor checks instruction surfaces first (`.cursorrules`,
`CLAUDE.md`, `AGENTS.md`, `package.json` scripts, `Makefile`,
`.vscode/tasks.json`) and reports per-finding severity, the verbatim payload
with hidden characters revealed, and a remediation.

## 4. Act on the verdict

- **Refuse-to-load findings** (hidden directives in rules files, postinstall
  exfiltration, curl-pipe-shell installs): delete the offending files before
  the repo touches an AI-assisted editor, or walk away.
- **Sanitize findings** (strippable hidden characters, HTML comments):
  apply the remediation from the report, re-run the audit, then proceed.
- **Clean**: open the repo normally. The auto-loaded discipline still treats
  its files as `REPO_UNTRUSTED` until you tell the agent you trust it.

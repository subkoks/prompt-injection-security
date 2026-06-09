# Local Setup (macOS)

Exact commands for install, daily use, and updates. Everything is SSH-first.

## Prerequisites

```bash
ssh-add -l                 # SSH key loaded in the agent
ssh -T git@github.com      # expect: "Hi subkoks! You've successfully authenticated..."
```

If the key is missing, stop and fix SSH before anything else — this repo
never uses HTTPS remotes.

## Install

```bash
cd ~/Projects
git clone git@github.com:subkoks/prompt-injection-security.git
cd prompt-injection-security
./install.sh               # symlinks skills + agent into detected editors
./healthcheck.sh           # verify everything
```

What the installer wires (only for editors present on the machine):

| Editor | Link |
|---|---|
| Cursor (canonical) | `~/.cursor/skills/{prompt-injection-security,injection-audit}` |
| Claude Code | `~/.claude/skills/*` -> Cursor canonical; `~/.claude/agents/injection-auditor.md` |
| Windsurf | `~/.codeium/windsurf/skills/*` |
| Agents mirror | `~/.agents/skills/*` |

## Daily use

```bash
./scripts/scan.sh <path>        # offline scan, exit 0/1/2
./scripts/git-status.sh         # branch / ahead-behind / dirty overview
./scripts/git-sync.sh "msg"     # pull --rebase, commit, push (never force)
```

In Claude Code: `/injection-audit <path-or-URL>` — the core skill needs no
invocation, it activates on untrusted content automatically.

## Update

```bash
cd ~/Projects/prompt-injection-security
./update.sh --check             # how far behind origin/main
./update.sh                     # pull --rebase + refresh symlinks + healthcheck
```

## Uninstall

```bash
./install.sh --uninstall        # removes only the symlinks it created
```

## Recommended git config: SSH everywhere

Rewrites every GitHub HTTPS URL to SSH automatically — clones, submodules,
and tool-generated remotes all come out as `git@github.com:`:

```ini
[url "git@github.com:"]
    insteadOf = https://github.com/
```

Apply with:

```bash
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

This is a recommendation, not applied by any script in this repo — it
changes global git behavior, so apply it deliberately.

## Troubleshooting

- `healthcheck.sh` says "not installed" — run `./install.sh`.
- A link points somewhere unexpected — the installer never overwrites real
  files or foreign symlinks targets it doesn't own; remove the offender
  manually and re-run `./install.sh`.
- `scan.sh` flags this repo's own docs — expected; see
  `tests/fixtures/README.md` and "Auditing this repo itself" in
  `docs/usage.md`.

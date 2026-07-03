# AGENTS.md

Repo-specific instructions for Codex CLI and other agents working in this repository.

## Scope

- This repo packages prompt-injection defense: skill, audit command, read-only auditor, offline scanner, and install/update scripts.
- Read `README.md` and `CLAUDE.md` before editing.
- Keep changes narrow and security-focused. Update the canonical skill or agent source first, not generated mirrors.

## Operating rules

- SSH only.
- One logical change per commit.
- Preserve the blackterminal voice: technical, direct, no fluff.
- Keep the auditor read-only.
- Use repo-local `.codex/config.toml` for Codex workspace defaults.

## Codex CLI notes

- Codex CLI should treat this file as the repo guidance source.
- Follow the existing branding and hidden-character constraints in `CLAUDE.md`.

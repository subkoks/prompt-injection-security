# Publish Checklist

Exact commands to create the private GitHub repo and push `main`. Nothing
here runs automatically — execute after explicit approval, in order.

## 0. Preflight (read-only, safe anytime)

```bash
cd ~/Projects/prompt-injection-security
gh auth status                      # logged in as subkoks, protocol ssh
ssh -T git@github.com               # expect: "Hi subkoks! ..."
git status --porcelain              # must be empty
git log --oneline                   # review what will be pushed
./healthcheck.sh --quick            # all green
```

## 1. Create the private repo

```bash
gh repo create subkoks/prompt-injection-security --private \
  --description "Prompt-injection defense for AI agent workflows: skeptical-reading skill, audit command, read-only auditor agent, offline scanner. A blackterminal project."
```

## 2. Add the SSH remote

```bash
git remote add origin git@github.com:subkoks/prompt-injection-security.git
git remote -v                       # both lines must show git@github.com:
```

## 3. Confirm branch

```bash
git branch --show-current           # main
```

## 4. First push

```bash
git push -u origin main
```

## 5. Verify sync

```bash
git ls-remote origin main           # remote head == local: git rev-parse HEAD
gh repo view subkoks/prompt-injection-security --json visibility,defaultBranchRef
# expect: "visibility": "PRIVATE", default branch "main"
gh run list --repo subkoks/prompt-injection-security --limit 3   # CI green
```

## Alternative without gh CLI

Create the repo in the GitHub web UI (Private, no README/license — the repo
already has both), then steps 2-5 unchanged.

## Hard rules

- Visibility stays PRIVATE; making it public is a separate, explicit
  decision.
- Plain `git push` only. Never `--force` on this repo.
- If the push is rejected, investigate with `git fetch origin && git log
  origin/main` — do not retry blindly.

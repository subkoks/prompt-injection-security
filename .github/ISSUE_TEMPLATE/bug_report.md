---
name: Bug report
about: Something detects wrong, fails to detect, or breaks
title: ""
labels: bug
assignees: subkoks
---

## What happened

Describe the bug.

## Expected behavior

What should have happened instead.

## Reproduction

- Command run (e.g. `./scripts/scan.sh <target>` or `/injection-audit <target>`):
- Minimal input that triggers the bug (sanitize anything sensitive; make
  hidden characters visible with `[ZWSP]`-style notation):
- Output / exit code:

## Environment

- OS: (macOS version / Linux distro)
- Bash: (`bash --version`, first line)
- Editor / agent runtime: (Claude Code, Cursor, Windsurf, other + version)
- Install method: (install.sh symlinks / manual copy / plugin)

## Notes

False negatives in the scanner are expected for novel techniques — include a
citation or sample payload if you are reporting a missed pattern.

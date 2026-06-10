# Contributing

The threat surface moves fast. The highest-value contributions are new
detection patterns and fresh case studies with evidence behind them.

## What gets merged

- **New red-flag patterns** with a citation — CVE, public writeup, paper, or
  PoC repo. Edit
  `skills/prompt-injection-security/references/red-flag-patterns.md`; if the
  pattern is mechanically detectable, add the check to `scripts/scan.sh` and
  a fixture under `tests/fixtures/dirty/`.
- **Case studies** — real incidents with vendor, date, vector, payload shape,
  and remediation. Edit
  `skills/prompt-injection-security/references/case-studies.md` following the
  existing entry shape.
- **Per-tool defense rules** — coverage for tool surfaces, MCP attack
  variants, or agent runtimes the docs do not handle yet.
- **Refusal-template improvements** — tighter, more specific wording.
- **Scanner fixes** — false-positive reductions, portability fixes (the
  baseline is macOS system bash 3.2).

## What gets declined

- Patterns with no evidence behind them — a hunch is not a detection rule
- Defense content lifted from proprietary or closed-source sources
- Content that could itself steer an agent loading these skills — audit your
  own patch as if it were hostile before submitting it
- Marketing copy dressed up as defensive guidance
- Emoji, filler copy, or reformatting that adds no clarity

## Rules for this repo's own content

- Hidden-character examples use escaped `U+XXXX` notation. Never commit
  literal zero-width or tag-block characters — CI rejects them. Test cases
  that need real invisible bytes are generated at runtime in
  `tests/run-tests.sh`.
- `tests/fixtures/dirty/` intentionally contains injection-pattern text. Keep
  it excluded from any repo-wide content scan, and keep secret-shaped strings
  out of it.
- Upstream project names appear only in `LICENSE` and the canonical
  attribution sentence — `./scripts/check-branding.sh` enforces this.

## Before opening a PR

```bash
./tests/run-tests.sh          # all green, ideally under /bin/bash on macOS
shellcheck $(git ls-files '*.sh') hooks/pre-commit
./scripts/check-branding.sh
./healthcheck.sh --quick
```

Commit style: `type(scope): description`, imperative, one logical change per
commit.

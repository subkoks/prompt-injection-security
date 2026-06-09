# Security Policy

## Reporting

Report vulnerabilities privately — do not open a public issue.

- Preferred: GitHub private vulnerability reporting on this repository
  (Security tab, "Report a vulnerability")
- Fallback: email subkoks@gmail.com with subject `[prompt-injection-security]`

Include: affected file or component, reproduction steps, impact, and a
payload sample if relevant (make hidden characters visible with
`[ZWSP]`-style notation).

Acknowledgement target: 72 hours.

## Scope

In scope:

- The skills and agent failing open — content that should be flagged but
  causes the discipline to be bypassed (e.g., wording in a SKILL.md that an
  injected payload can subvert)
- `scripts/scan.sh` vulnerabilities: command injection via crafted filenames
  or content, detection bypasses for the pattern classes it claims to cover
- `install.sh` / `update.sh` / `healthcheck.sh` doing anything outside their
  documented file-and-symlink contract
- A contribution to this repo that itself functions as an injection vector
  against agents loading the skills

Out of scope:

- Novel injection techniques the skill does not yet document — that is a
  feature request (with citation), not a vulnerability
- Scanner false negatives by design: `scan.sh` is a fast first pass, not a
  complete defense
- Issues in the editors and agent runtimes that load these skills

## Supported versions

Only the latest release on `main` is supported.

## Note on repository content

This repo deliberately contains injection-pattern text in
`skills/prompt-injection-security/references/` and `tests/fixtures/dirty/` as
documentation and test data. Reports that these files "contain injections"
are expected behavior, not findings. If a secret scanner is ever added,
allowlist `tests/fixtures/` first.

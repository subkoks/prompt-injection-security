## What this changes

One or two sentences.

## Why

Link the issue, CVE, or writeup that motivates the change.

## Checklist

- [ ] `./tests/run-tests.sh` passes (under macOS `/bin/bash` if available)
- [ ] `shellcheck` clean on any touched shell script
- [ ] `./scripts/check-branding.sh` passes
- [ ] No literal hidden Unicode added (zero-width / tag-block characters);
      hidden-character examples use escaped `U+XXXX` notation
- [ ] New scanner patterns come with a `tests/fixtures/` case (or a
      runtime-generated case in `tests/run-tests.sh` if the payload is
      invisible)
- [ ] No secret-shaped strings in fixtures or docs

# Testing

## Summary

There is no centralized automated test suite at the repository root. Validation is mostly manual, file-based, and domain-specific: RouterOS scripts are linted or dry-run imported, while documentation and setup scripts are verified by inspection or controlled execution.

## Current Validation Paths

- `python skills/mikrotik-routeros-rsc/scripts/lint_rsc.py path/to/script.rsc` for RouterOS syntax and safety checks.
- RouterOS `import ... dry-run` for syntax validation without applying configuration.
- Manual execution of `need-more-tokens.sh` in a controlled shell environment.
- Manual review of `docs/best-setup-ever.md` for setup correctness and consistency.

## What Is Not Present

- No root-level test runner such as `pytest`, `npm test`, or `cargo test`.
- No CI configuration was found in the visible repository structure.
- No fixture-based automated regression suite for the docs or setup script.

## Testing Style by Area

- RouterOS: prefer linting, dry-run import, and `on-error`-style failure capture.
- Bash: prefer shellcheck-style review and stepwise execution in a disposable shell.
- Documentation: check command accuracy, file path accuracy, and internal consistency.

## Coverage Gaps

- `need-more-tokens.sh` appears to depend on many external network calls and package installers, so it needs careful sandbox testing.
- The repo would benefit from a repeatable verification script if the setup guide becomes a maintained product instead of a reference note.
- The current docs do not define an automated acceptance test for the suggested token-saving stack.

## Practical Recommendation

- Treat manual verification as the current baseline.
- Add lightweight lint or smoke tests only if a future phase turns one of the scripts into a supported workflow artifact.
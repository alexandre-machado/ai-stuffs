# Conventions

## Summary

The repository uses a documentation-heavy style: short index files at the root, detailed Markdown guides under `docs/`, and skill-specific instructions under `skills/`. The tone mixes English and Portuguese depending on the document audience.

## Writing Conventions

- Prefer clear headings and short sections over large narrative blocks.
- Use fenced code blocks for commands, scripts, and configuration.
- Keep repo-index files concise and push detail into the relevant guide or skill file.
- Use descriptive filenames that match the content rather than generic names.

## Skill Conventions

- Skill content lives in `SKILL.md` with optional `references/` and `scripts/` subfolders.
- RouterOS guidance emphasizes idempotency, security, and safe import behavior.
- Validation helpers should be explicit and scriptable, as shown by `scripts/lint_rsc.py`.

## Shell Conventions

- `need-more-tokens.sh` is written as a defensive Bash script with `set -euo pipefail`.
- The script prefers idempotent edits to shell rc files and guards commands with existence checks.
- Environment bootstrap steps are organized as numbered phases for readability.

## Configuration Conventions

- JSON config is minimal and direct, as in `opencode.json`.
- Repository guidance prefers local, file-based configuration over hidden application state.
- Setup documents assume common POSIX tooling and a user-managed shell profile.

## Error-Handling Conventions

- RouterOS material favors `:onerror`, `on-error`, and dry-run validation over blind import.
- Bash automation should fail fast and surface clear install-time errors.
- Documentation should call out constraints and caveats explicitly rather than leaving them implicit.
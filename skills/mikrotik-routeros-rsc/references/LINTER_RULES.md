# Linter Rules (.rsc)

The linter applies basic static checks for security and idempotency.

## Rules
- Forbid destructive commands: `system reset-configuration`, formatting, wipe.
- Alert `import` inside script (should be used at root terminal).
- Alert excessive policies in `/system script add policy=...` (prefer minimum necessary).
- Alert `add` without guard (`find where ...` + `:if`), for common menus (IP/Firewall/etc.).
- Alert `set`/`remove` referring to `numbers` (fixed IDs) instead of `find`.
- Alert `:delay` in loops without limits.
- Alert `:global` inside local scopes without external re-reference.
- Alert `log` with terms like `password`, `secret`, `token`.

## Limitations
- Analysis is per-line; does not comprehend entire flow or router state.
- Rules are heuristics; require human review.

## Usage
- `python scripts/lint_rsc.py path/to/script.rsc`
- Output: warnings with line number and rule.

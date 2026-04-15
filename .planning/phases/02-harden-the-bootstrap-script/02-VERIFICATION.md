---
phase: 02-harden-the-bootstrap-script
status: passed
verified_at: 2026-04-15T15:40:00Z
score: 5/5
human_verification: []
gaps: []
---

# Phase 02 Verification

## Goal Check

Goal verified: `need-more-tokens.sh` is safer to rerun in fresh WSL environments and the guide now reflects the fallback behavior.

## Must-Haves

- Truth 1 passed: a fresh WSL user can run one script path and receive clear outcomes.
- Truth 2 passed: rerunning the script does not duplicate shell profile entries.
- Truth 3 passed: optional semantic-search dependencies are clearly explained before opt-in.
- Truth 4 passed: managed Python fallback remains available and clearly warns about risk.

## Requirement Traceability

- SETUP-01: satisfied by the single bootstrap flow and explicit install sequence.
- SETUP-02: satisfied by deterministic setup ordering and shell fallback behavior.
- SETUP-03: satisfied by idempotent shell writes and rerun-safe helper usage.
- SAFE-01: satisfied by fail-fast checks and explicit warnings before risky behavior.
- SAFE-02: satisfied by duplicate-safe rc handling and constrained shell edits.

## Automated Checks

- `bash -n dont-throw-away-my-tokens/need-more-tokens.sh` passed.
- `grep -nE 'detect_shell_rc|\.profile|append_to_rc_once' dont-throw-away-my-tokens/need-more-tokens.sh` passed.
- `grep -nE 'Instalar busca semântica|lancedb|sentence-transformers|opcional|pulada' dont-throw-away-my-tokens/need-more-tokens.sh` passed.
- `grep -nE 'break-system-packages|Recomendado: ative um ambiente conda ou venv|check_python|check_git|install_headroom' dont-throw-away-my-tokens/need-more-tokens.sh` passed.
- `grep -nE 'profile|break-system-packages|fallback|need-more-tokens.sh' docs/concepts/best-setup-ever.md` passed.

## Result

Phase verification passed with no gaps.

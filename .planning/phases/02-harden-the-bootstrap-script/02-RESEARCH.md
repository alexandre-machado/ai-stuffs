# Phase 2: Harden the bootstrap script - Research

**Date:** 2026-04-15
**Phase:** 02-harden-the-bootstrap-script
**Goal:** Make `dont-throw-away-my-tokens/setup.sh` a repeatable, safer bootstrap path for a fresh WSL environment.

## Summary

Phase 2 should keep the current local-first bootstrap model while hardening script behavior around shell profile handling, managed Python fallback, installation ordering, and user-facing consequence prompts. The implementation should remain idempotent and rerunnable.

## Confirmed Inputs

- Source script: `dont-throw-away-my-tokens/setup.sh`
- Scope decisions: `02-CONTEXT.md` (D-01 to D-05)
- Requirement IDs: SETUP-01, SETUP-02, SETUP-03, SAFE-01, SAFE-02

## Existing Baseline Patterns

- Defensive shell mode is already enabled: `set -euo pipefail`.
- Idempotent rc-file mutation exists via `append_to_rc_once`.
- Installation flow is structured by function boundaries (`install_headroom`, `install_rtk`, `install_memstack`).
- Interactive and non-interactive behavior already coexist (`ASSUME_YES`, env vars).

## Architecture Patterns To Keep

- Single-script orchestration with clear preflight checks (`check_python`, `check_git`).
- Explicit, human-readable status output (`info`, `success`, `warn`, `die`).
- Function-scoped behavior with minimal shared mutable state.
- Idempotent shell profile writes only through one helper.

## Key Design Constraints From Context

- D-01: Keep prompting for MemStack target (global/project/custom).
- D-02 and D-03: Semantic search remains opt-in with concise explicit consequences.
- D-04: Add fallback to `~/.profile` when shell-specific rc files are not applicable.
- D-05: Keep managed Python fallback using `--break-system-packages`, with clear warning text.

## Recommended Implementation Focus

1. **Shell profile resolution hardening**
- Extend `detect_shell_rc` to support fallback to `~/.profile` in unknown-shell contexts.
- Preserve `.bashrc`/`.zshrc` priority when known and available.

2. **Consequence-driven prompt for optional semantic deps**
- Keep opt-in model.
- Prompt text should explicitly call out tradeoff: heavier install vs no semantic features.

3. **Python fallback clarity and safety messaging**
- Keep fallback behavior for fresh WSL reliability.
- Keep warning path explicit when `--break-system-packages` is engaged.

4. **Install ordering and failure visibility**
- Keep sequence deterministic and fail-fast.
- Ensure each install block leaves a clear user-facing action when a non-fatal fallback is used.

## Common Pitfalls To Avoid

- Silent fallback behavior that obscures whether system Python was modified.
- Prompt text that is too verbose or too vague for interactive/non-interactive parity.
- Breaking idempotence by adding direct rc-file writes outside `append_to_rc_once`.
- Reordering installs in ways that violate existing assumptions (e.g., relying on tools before PATH/env updates are in place).

## Dont Hand-Roll

- Do not add a custom rc-file parser; use current helper pattern.
- Do not add a new config format for choices; reuse existing env var + prompt flow.
- Do not replace shell-safe helper logging/error abstractions already in use.

## Verification Approach For Planning

- `bash -n dont-throw-away-my-tokens/setup.sh` must pass.
- `grep` checks should confirm:
  - `~/.profile` fallback handling is present.
  - Semantic-search prompt includes concise consequence language.
  - Managed Python fallback warning remains explicit.
- Re-run safety: no duplicate rc entries when script is executed repeatedly.

---

*Research complete for Phase 2 planning.*

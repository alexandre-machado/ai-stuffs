---
phase: 02-harden-the-bootstrap-script
plan: 01
subsystem: infra
tags: [bash, bootstrap, wsl, shell, python, docs]
requires: []
provides:
  - "Safer bootstrap script behavior for shell profile targeting, semantic-search opt-in, and managed-Python fallback messaging"
  - "Docs note aligned with the hardened bootstrap behavior"
affects: [phase-03-monitoring-guidance]
tech-stack:
  added: []
  patterns: ["Idempotent rc-file writes", "Explicit opt-in prompts with consequence messaging", "Managed Python fallback with warnings"]
key-files:
  created: [.planning/phases/02-harden-the-bootstrap-script/02-01-SUMMARY.md, .planning/phases/02-harden-the-bootstrap-script/02-VERIFICATION.md]
  modified: [dont-throw-away-my-tokens/need-more-tokens.sh, docs/concepts/best-setup-ever.md]
key-decisions:
  - "Added ~/.profile fallback when shell-specific rc files are unavailable"
  - "Kept semantic-search dependencies opt-in with concise consequence messaging"
  - "Preserved managed-Python fallback with --break-system-packages warnings"
patterns-established:
  - "The bootstrap script should prefer explicit user-facing tradeoffs over silent defaults"
  - "Documentation should mirror shell and Python fallback behavior in the runnable script"
requirements-completed: [SETUP-01, SETUP-02, SETUP-03, SAFE-01, SAFE-02]
duration: 28min
completed: 2026-04-15
---

# Phase 2: Harden the bootstrap script Summary

**Safer WSL bootstrap flow with `.profile` fallback, opt-in semantic dependencies, and explicit managed-Python warnings**

## Performance

- **Duration:** 28 min
- **Started:** 2026-04-15T15:10:00Z
- **Completed:** 2026-04-15T15:38:00Z
- **Tasks:** 3
- **Files modified:** 2

## Accomplishments
- Hardened shell profile resolution so unknown shells fall back to `~/.profile` instead of failing silently.
- Kept semantic-search dependencies opt-in and made the install consequence explicit in the prompt.
- Preserved the managed-Python fallback path and aligned the setup guide with the script's behavior.

## Task Commits

Each task was committed atomically:

1. **Task 1: Harden shell profile target resolution and idempotent writes** - `96f9027` (feat)
2. **Task 2: Keep semantic dependencies opt-in with concise consequence messaging** - `438d6aa` (feat)
3. **Task 3: Preserve managed-Python fallback and align docs with hardened behavior** - `1a0d25a` (docs)

## Files Created/Modified
- `dont-throw-away-my-tokens/need-more-tokens.sh` - Script hardening for shell rc fallback and prompt clarity.
- `docs/concepts/best-setup-ever.md` - Added a concise note about reruns and fallback behavior.

## Decisions Made
- Keep the bootstrap path practical for fresh WSL users rather than forcing stricter environment setup.
- Keep opt-in semantics for heavier semantic-search dependencies and tell the user exactly what changes.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- The setup guide lives at `docs/concepts/best-setup-ever.md`, not `docs/best-setup-ever.md`.
- The script had been moved to `dont-throw-away-my-tokens/need-more-tokens.sh` before execution, so plan references were updated to match the current path.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 2 is complete and ready for the monitoring/guidance phase.
- The script now has explicit fallback behavior documented for reruns on fresh WSL.

---
*Phase: 02-harden-the-bootstrap-script*
*Completed: 2026-04-15*

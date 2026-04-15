# Phase 2: Harden the bootstrap script - Context

**Gathered:** 2026-04-15
**Status:** Ready for planning

<domain>
## Phase Boundary

Harden `need-more-tokens.sh` into a safer, repeatable bootstrap path for fresh WSL/Linux setups, with idempotent shell edits, safer environment detection/ordering, and clearer failure handling. This phase does not add new product capabilities.

</domain>

<decisions>
## Implementation Decisions

### MemStack install target behavior
- **D-01:** Keep prompting the user to choose MemStack installation target (global vs per-project vs custom path) instead of forcing a single default.

### Optional semantic search dependencies
- **D-02:** Keep semantic search dependencies opt-in behind an explicit prompt/flag, and show a concise explanation of consequences before choice.
- **D-03:** Consequences text must explain both outcomes: opting in installs heavier dependencies (`lancedb` and `sentence-transformers`) for semantic features; opting out keeps setup lighter/faster but leaves semantic search unavailable.

### Shell startup file handling
- **D-04:** Add fallback to `~/.profile` when shell-specific rc detection (`.bashrc` or `.zshrc`) is not available.

### Python environment policy
- **D-05:** Keep the fallback behavior that allows managed system Python using `--break-system-packages` (with explicit warnings), rather than hard-failing unless venv/conda is active.

### the agent's Discretion
- Exact phrasing for warnings and prompts, as long as it stays concise and explicit.
- Internal function naming and script structure for implementing these decisions.

</decisions>

<specifics>
## Specific Ideas

- The hardening pass should prioritize practical fresh-WSL reliability, while still warning clearly when fallback behavior may be riskier.
- User requested additional pros/cons on Python policy during discussion and selected to keep fallback.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase and requirement scope
- `.planning/ROADMAP.md` — Defines Phase 2 goal, deliverables, and requirement coverage (SETUP-01/02/03, SAFE-01/02).
- `.planning/REQUIREMENTS.md` — Source of setup and safety requirement IDs mapped to Phase 2.
- `.planning/PROJECT.md` — Project-level constraints, out-of-scope boundaries, and local-first/idempotence principles.

### Bootstrap implementation baseline
- `need-more-tokens.sh` — Existing script behavior to harden (prompt flow, Python fallback, shell rc handling, dependency installs).
- `docs/best-setup-ever.md` — Setup guide and architecture context that script behavior should align with.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `detect_shell_rc` and `append_to_rc_once` in `need-more-tokens.sh` already implement idempotent rc-file mutations and should be reused for Phase 2 hardening.
- `check_python`, `install_semantic_search`, and `resolve_memstack_target` functions provide existing extension points for the selected decisions.

### Established Patterns
- Script uses defensive shell defaults (`set -euo pipefail`) and explicit helper functions (`info`, `warn`, `die`).
- User-facing choices already support interactive + non-interactive modes (`-y` plus env vars); hardening should preserve that model.

### Integration Points
- Python dependency installs and fallback policy are centralized in `check_python` and pip calls.
- Startup-file writes flow through `detect_shell_rc` and `append_to_rc_once`.
- Semantic-search install choice flows through `install_semantic_search`.

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-harden-the-bootstrap-script*
*Context gathered: 2026-04-15*

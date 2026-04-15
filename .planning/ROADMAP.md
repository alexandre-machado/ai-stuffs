# Roadmap: Best AI Setup Ever

### Phase 1: Define the setup contract

**Goal:** Turn the existing guide into a clear project definition with a stable scope, named project, and checkable requirements.

**Why this phase exists:** The repo already contains the material, but the project needs an explicit contract before any hardening work is worth doing.

**Plans:** 1 plan

Plans:
- [x] 01-01-PLAN.md — Finalize the setup contract and traceability

**Deliverables:**
- Confirmed project framing in `PROJECT.md`
- Scoped and traceable requirements in `REQUIREMENTS.md`
- Updated project state in `STATE.md`

**Covers:**
- DOCS-01
- DOCS-02

**Depends on:**
- Codebase map

### Phase 2: Harden the bootstrap script

**Goal:** Make `need-more-tokens.sh` a repeatable, safer bootstrap path for a fresh WSL environment.

**Why this phase exists:** The script is the part most likely to fail in real use because it depends on external installs, rc-file edits, and shell assumptions.

**Deliverables:**
- Idempotent shell configuration changes
- Safer environment detection and install ordering
- Clear failure handling for missing prerequisites and external tools

**Covers:**
- SETUP-01
- SETUP-02
- SETUP-03
- SAFE-01
- SAFE-02

**Plans:** 1 plan

Plans:
- [x] 02-01-PLAN.md — Harden script safety, fallback behavior, and docs alignment

**Depends on:**
- Phase 1

### Phase 3: Tighten monitoring and operator guidance

**Goal:** Make the setup easier to use after install by documenting how to confirm savings, inspect usage, and know when to skip an aggressive optimization.

**Why this phase exists:** The workflow only pays off if users can tell whether it is helping and when a tool should be excluded from compression.

**Deliverables:**
- Monitoring guidance for ccusage and Claude Monitor
- Tool-selection guidance for risky or full-output commands
- Documentation cleanup so the guide remains readable as a single source of truth

**Covers:**
- MON-01
- MON-02

**Plans:** 1 plan

Plans:
- [x] 03-01-PLAN.md — Refine ccusage-first monitoring and skip-rule guidance

**Depends on:**
- Phase 2

### Phase Notes

- Phase 1 is the setup-contract gate for all downstream script hardening and monitoring work.
- The project is intentionally local-first and documentation-heavy.
- External tooling stays out of scope; the roadmap focuses on orchestration, safety, and repeatability.
- If validation reveals the guide and script are already production-ready, the remaining work becomes documentation polish and verification rather than major feature work.
# Requirements: Best AI Setup Ever

**Defined:** 2026-04-15
**Core Value:** Make the AI coding environment easy to stand up, safe to rerun, and cheaper to use by default.

## v1 Requirements

### Setup Flow

- [ ] **SETUP-01**: User can install the documented WSL prerequisites and token-saving tools from a single bootstrap flow.
- [ ] **SETUP-02**: User can run the bootstrap script in a fresh WSL environment without manually reconstructing the order of steps.
- [ ] **SETUP-03**: User can rerun the bootstrap script without duplicating shell configuration or breaking existing installs.

### Guidance and Visibility

These requirements define the Phase 1 setup contract and are sourced from `docs/best-setup-ever.md`.

- [x] **DOCS-01**: User can understand the architecture, prerequisites, and commands from the setup guide without reading multiple files.
- [x] **DOCS-02**: User can see where RTK, Headroom, MemStack, and monitoring fit in the overall workflow.

### Monitoring

- [x] **MON-01**: User can check token usage and savings with ccusage or Claude Monitor after setup.
- [x] **MON-02**: User can tell when a tool should be skipped or excluded because it needs full output or has high-risk side effects.

### Safety

- [ ] **SAFE-01**: Setup steps avoid destructive shell or system actions by default.
- [ ] **SAFE-02**: Shell profile edits are idempotent and limited to the token-optimization configuration.

## v2 Requirements

### Platform Extensions

- **ADV-01**: Add cross-shell support beyond Bash and zsh.
- **ADV-02**: Package the flow as a distributable installer with automatic rollback.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Implementing RTK, Headroom, MemStack, ccusage, or Claude Monitor | They are external tools; this project orchestrates and documents them. |
| Cloud-hosted setup service | The goal is a local-first WSL bootstrap, not a central provisioning platform. |
| RouterOS skill changes | That skill already exists and belongs to a separate domain. |
| Enterprise policy management or multi-user fleet rollout | Adds a different operational model than the one described in the guide. |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| DOCS-01 | Phase 1 | Complete |
| DOCS-02 | Phase 1 | Complete |
| SETUP-01 | Phase 2 | Pending |
| SETUP-02 | Phase 2 | Pending |
| SETUP-03 | Phase 2 | Pending |
| SAFE-01 | Phase 2 | Pending |
| SAFE-02 | Phase 2 | Pending |
| MON-01 | Phase 3 | Complete |
| MON-02 | Phase 3 | Complete |

**Coverage:**
- v1 requirements: 9 total
- Mapped to phases: 9
- Unmapped: 0

---
*Requirements defined: 2026-04-15*
*Last updated: 2026-04-15 after initialization*

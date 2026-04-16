# Best AI Setup Ever

## What This Is

This is a WSL-first setup and bootstrap project for AI coding workflows. It packages a repeatable path for setting up RTK, Headroom, MemStack, and monitoring tools so a developer can reduce token waste without having to reconstruct the environment from scratch every time.

The intended user is someone working in WSL or Linux who wants a practical, local-first way to install, configure, and monitor an AI coding stack.

## Core Value

Make the AI coding environment easy to stand up, safe to rerun, and cheaper to use by default.

## Requirements

### Validated

- ✓ The repo already contains a consolidated WSL token-optimization guide in `docs/best-setup-ever.md` - existing baseline
- ✓ The repo already contains a bootstrap script in `setup.sh` that stages the setup flow - existing baseline
- ✓ The repo already contains a RouterOS skill package with references and linting support - existing baseline, but separate from this project

### Active

- [ ] Turn the setup guide into a reliable, runnable bootstrap path for WSL users.
- [ ] Keep the setup flow local-first, idempotent, and easy to audit before execution.
- [ ] Document the environment, constraints, and monitoring commands in one place.

### Out of Scope

- RTK, Headroom, MemStack, ccusage, and Claude Monitor implementation work - they are external tools, not this repo's responsibility.
- Cloud-hosted or centrally managed setup services - the workflow is intentionally local and user-run.
- Reworking the RouterOS skill into this project - it is a separate skill package with its own lifecycle.

## Context

The repo is a small docs and skills bundle. `docs/best-setup-ever.md` describes a three-layer stack: RTK for shell output compression, Headroom for prompt/context compression, and MemStack for cross-session memory, plus monitoring through `ccusage` and `cmonitor`. `setup.sh` is the practical bootstrap script, and `opencode.json` points at a local Foundry provider.

The working name for this project is `best-ai-setup-ever`, matching the path the user requested and the scope of the setup guide.

## Constraints

- **Environment**: WSL/Linux-first - the setup assumes Bash, curl, Python 3, Git, and shell rc files.
- **Dependency**: External package and installer dependencies - the bootstrap flow relies on third-party tools and remote downloads.
- **Safety**: Idempotent shell changes - startup file edits and install steps need to be repeatable and reviewable.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Project name: Best AI Setup Ever | Matches the requested path and clearly describes the goal | Confirmed in Phase 1 setup contract |
| Treat the repo as brownfield | Existing docs and script already establish a meaningful baseline | Confirmed from current repository baseline |
| Keep external tools out of scope | The project should orchestrate the setup, not reimplement the tooling | Confirmed as a standing scope boundary |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition**:
1. Requirements invalidated? Move them to Out of Scope with reason.
2. Requirements validated? Move them to Validated with phase reference.
3. New requirements emerged? Add them to Active.
4. Decisions to log? Add them to Key Decisions.
5. Does What This Is still match reality? Update it if it drifted.

**After each milestone**:
1. Review all sections.
2. Recheck Core Value.
3. Audit Out of Scope reasons.
4. Update Context with current state.

---
*Last updated: 2026-04-15 after initialization*

# Phase 3: Tighten monitoring and operator guidance - Research

**Date:** 2026-04-15
**Phase:** 03-tighten-monitoring-and-operator-guidance
**Goal:** Make the setup easier to use after install by documenting how to confirm savings, inspect usage, and know when to skip aggressive optimization.

## Summary

Phase 3 is documentation-only and should optimize operator decision quality, not add tooling. The existing guide already has monitoring commands; the work is to reorder and clarify guidance so `ccusage` is primary, skip rules are practical, and shell-customization examples are avoided in the operator guidance flow.

## Confirmed Inputs

- Scope decisions from `03-CONTEXT.md`:
  - D-01: Prioritize `ccusage` first; Claude Monitor secondary.
  - D-02: Keep a single narrative guidance section.
  - D-03: Use broad rule-based skip guidance.
  - D-04: Avoid shell customization examples.
- Requirement IDs: MON-01, MON-02.
- Baseline guide: `docs/concepts/best-setup-ever.md`.

## Existing Baseline

- Monitoring section already includes `ccusage` command variants and a Claude Monitor subsection.
- Session habits section already addresses behavioral token-efficiency rules.
- The guide includes a large bootstrap script block with aliases and convenience shell shortcuts; this should not be expanded in Phase 3.

## Architecture/Documentation Patterns To Keep

- Documentation-first edits, no runtime/system changes.
- Commands remain explicit and copy-paste-friendly.
- Explanations stay concise and action-oriented.

## Recommended Editing Strategy

1. Reframe monitoring flow so users start with `ccusage` for baseline visibility, then use Claude Monitor for live burn-rate views.
2. Add/strengthen one narrative operator section describing when to skip optimization tools (full-output commands, risky side-effect operations, debugging contexts where lossless output is required).
3. Keep shell customization out of the guidance path (no new alias snippets, no shortcut-heavy operator instructions).
4. Trim or reorganize overlapping text if needed so guidance reads as one coherent narrative rather than fragmented checklist blocks.

## Pitfalls To Avoid

- Introducing new dependencies/tools in this phase.
- Turning guidance into shell personalization instructions.
- Contradicting prior phase constraints about local-first and explicit risk signaling.
- Splitting guidance into many isolated tables or micro-sections (conflicts with D-02 narrative decision).

## Verification Approach For Planning

- Grep checks should confirm `ccusage` appears as first-class monitoring guidance.
- Documentation includes explicit rule-based skip guidance (keywords: full output, side effects, risky commands, skip optimization).
- No newly introduced alias/shortcut guidance in the updated operator section.

---

*Research complete for Phase 3 planning.*

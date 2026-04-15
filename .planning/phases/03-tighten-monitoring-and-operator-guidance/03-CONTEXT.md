# Phase 3: Tighten monitoring and operator guidance - Context

**Gathered:** 2026-04-15
**Status:** Ready for planning

<domain>
## Phase Boundary

Improve the post-install guidance for monitoring token usage and deciding when to skip or avoid aggressive optimization tools. This phase stays within documentation and operator guidance; it does not add new tooling.

</domain>

<decisions>
## Implementation Decisions

### Monitoring priority
- **D-01:** Center the guide on `ccusage` first, then present Claude Monitor as the secondary real-time option.

### Guidance structure
- **D-02:** Keep the operator guidance as a single narrative section rather than splitting it into a quick-reference table and separate examples.

### Tool-skip guidance
- **D-03:** Use broad rule-based guidance for when to skip a tool or command, and let the agent decide the exact examples to call out.

### Shell customization
- **D-04:** Avoid shell customization examples such as aliases or shortcuts in the Phase 3 guidance.

### the agent's Discretion
- Exact wording for the guidance narrative, as long as it remains concise and readable.
- Which specific risky commands or situations to name under the broader skip-rule guidance.
- Whether the documentation should emphasize `ccusage` commands that do not require installation versus the real-time monitor workflow.

</decisions>

<specifics>
## Specific Ideas

- The guide should help users confirm savings and understand when to skip a tool without turning into a command-alias cookbook.
- User selected `ccusage` as the primary monitoring focus and asked to avoid shell customization.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase and requirement scope
- `.planning/ROADMAP.md` — Defines Phase 3 goal, deliverables, and requirement coverage (MON-01, MON-02).
- `.planning/REQUIREMENTS.md` — Source of monitoring and skip-rule requirement IDs mapped to Phase 3.
- `.planning/PROJECT.md` — Project-level constraints, out-of-scope boundaries, and local-first/idempotence principles.

### Monitoring and guide baseline
- `docs/concepts/best-setup-ever.md` — Current monitoring section, operator guidance, and examples to refine.
- `.planning/phases/02-harden-the-bootstrap-script/02-01-SUMMARY.md` — Phase 2 fallback behavior and guide-alignment decisions that Phase 3 should respect.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- The monitoring section in `docs/concepts/best-setup-ever.md` already distinguishes `ccusage` from Claude Monitor and can be reorganized without adding new tooling.

### Established Patterns
- The repo prefers concise Markdown sections with command examples and brief justifications.
- Prior phases kept shell customization and installation behavior tightly scoped, which should continue here.

### Integration Points
- This phase updates documentation only; there is no script or runtime integration point to change.
- The existing monitoring commands in the guide are the primary source for any reordering or emphasis changes.

</code_context>

<deferred>
## Deferred Ideas

- Shell aliases or shortcut snippets for monitoring commands — out of scope for this phase.
- A separate quick-reference table — not chosen for this phase; keep the guidance as one narrative section.

</deferred>

---

*Phase: 03-tighten-monitoring-and-operator-guidance*
*Context gathered: 2026-04-15*

# Architecture

## Overview

The repository is organized as a small knowledge base plus a single practical skill package. The top level provides orientation documents, a token-optimization setup guide, and an installer-style Bash script, while `skills/mikrotik-routeros-rsc` contains the only implemented skill with references and a linter.

## Layout Pattern

- Documentation-first repo root.
- One skill subtree per domain under `skills/`.
- Supporting reference material grouped under `skills/<skill>/references/`.
- Helper automation placed under `skills/<skill>/scripts/`.

## Main Entry Points

- `README.md` and `AGENTS.md` act as the repo index.
- `docs/best-setup-ever.md` is the long-form setup and architecture guide for token-reduction tooling.
- `need-more-tokens.sh` is the executable bootstrap path for the token-saver workflow.
- `skills/mikrotik-routeros-rsc/SKILL.md` is the canonical instruction file for the RouterOS skill.

## Data Flow

- Users install the skill from GitHub or read the docs locally.
- RouterOS instructions are routed through the skill file and its references.
- The setup guide feeds shell/bootstrap steps into the `need-more-tokens.sh` script and into manual environment setup.
- Validation flows from the skill into `skills/mikrotik-routeros-rsc/scripts/lint_rsc.py` and RouterOS import dry-run procedures.

## Abstractions

- Skill metadata lives in Markdown frontmatter and prose instructions.
- Reference documents capture language rules, safe practices, examples, and linter rules for RouterOS.
- The setup guide separates concerns into RTK, Headroom, MemStack, and monitoring layers.

## Architectural Notes

- This repo does not expose an application API or service layer.
- The architecture is intentionally lightweight and file-based, with shell commands and docs acting as the interface.
- Most changes should preserve the simple repository shape and avoid introducing framework overhead unless a new skill genuinely needs it.
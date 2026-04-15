# Structure

## Top-Level Layout

- `README.md` - repository overview and install entry point.
- `AGENTS.md` - master index for the available skill.
- `docs/` - long-form guidance and setup documentation.
- `need-more-tokens.sh` - Bash automation script for bootstrapping the token-saver stack.
- `opencode.json` - local OpenCode provider configuration.
- `basic-npu-chat/` - auxiliary example project folder.
- `local-foundry-agentic-cli/` - auxiliary example project folder.
- `openai-server/` - auxiliary example project folder.
- `skills/` - skill packages.

## Skill Tree

- `skills/mikrotik-routeros-rsc/SKILL.md` - RouterOS skill instructions.
- `skills/mikrotik-routeros-rsc/references/` - language, guide, safe practices, examples, and linter rules.
- `skills/mikrotik-routeros-rsc/scripts/lint_rsc.py` - validation script.

## Documentation Tree

- `docs/best-setup-ever.md` - detailed WSL and token-saving setup guide.

## Naming Conventions

- Skill directories use kebab-case and match their skill names.
- Primary instruction files use `SKILL.md` inside each skill directory.
- Supporting materials are separated into `references/` and `scripts/` subdirectories.
- Repository-level documents use descriptive Markdown filenames rather than app-style module names.

## Practical Reading Order

1. `README.md` or `AGENTS.md` for the repo summary.
2. `skills/mikrotik-routeros-rsc/SKILL.md` for the actual skill workflow.
3. `docs/best-setup-ever.md` for the token-optimization architecture.
4. `need-more-tokens.sh` for the runnable setup path.

## Structural Notes

- There is no conventional application source tree such as `src/` or `app/` at the repo root.
- The repository is better treated as a curated set of docs and automation assets than as a single product codebase.
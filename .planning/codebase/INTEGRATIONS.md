# Integrations

## Summary

This repository integrates with a few external surfaces, but they are mostly reference-driven rather than wired into a live application. The main integration point is the RouterOS skill package, plus the setup guide that references token-management tools and local model infrastructure.

## External Systems

- GitHub as the distribution channel for `alexandre-machado/ai-stuffs` and the source of the RouterOS skill installation flow.
- MikroTik RouterOS devices for the `.rsc` skill and its lint/import workflow.
- Local AI tooling referenced by the docs, including Claude Code, Copilot, Gemini CLI, and OpenCode.
- Microsoft Foundry via the `opencode.json` provider configuration.

## Tool and Service References

- `npx skills add alexandre-machado/ai-stuffs --skill mikrotik-routeros-rsc` is the documented install path.
- `rtk`, `headroom`, `memstack`, `ccusage`, and `cmonitor` are external tools described in `docs/best-setup-ever.md`.
- The setup guide also references `claude-monitor`, `lancedb`, and `sentence-transformers` as optional environment components.

## Local Configuration Touchpoints

- `opencode.json` points at `http://127.0.0.1:50286/v1` with a local API key placeholder, which implies a local model server or proxy must already exist.
- `need-more-tokens.sh` writes shell configuration that assumes `~/.bashrc` or `~/.zshrc` is the correct shell startup file.
- The RouterOS skill references a local Python linter script at `skills/mikrotik-routeros-rsc/scripts/lint_rsc.py`.

## Integration Characteristics

- No persistent backend, database, or authentication provider is defined at the repo root.
- Existing integrations are mostly documentation examples, installer commands, and validation helpers.
- The repo is safe to treat as a reference and tooling bundle rather than an app with runtime service dependencies.
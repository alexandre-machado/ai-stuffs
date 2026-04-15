# Stack

## Summary

This repository is a documentation and skill bundle, not a compiled application. The primary assets are Markdown documents, a Bash setup script, JSON configuration, and one RouterOS skill with Python-based validation helpers.

## Languages and Runtimes

- Markdown for project documentation and skill instructions.
- Bash for automation in `need-more-tokens.sh` and setup snippets inside docs.
- JSON for configuration in `opencode.json` and generated planning files.
- Python 3 for the RouterOS linter in `skills/mikrotik-routeros-rsc/scripts/lint_rsc.py`.

## Key Tooling

- `npx skills add ...` for packaging and installing the skill from this repository.
- `python scripts/lint_rsc.py` for RouterOS script validation.
- Standard Unix shell tools such as `git`, `curl`, `python3`, `pip`, and `nvm` in the setup guide.

## Repository-Level Configuration

- `opencode.json` configures a local OpenCode provider pointing at Microsoft Foundry on `http://127.0.0.1:50286/v1`.
- `need-more-tokens.sh` assumes an environment with Bash, Python 3.10+, Git, curl, and internet access for package installation.
- The skill content expects RouterOS v7 where possible, with v6 compatibility where practical.

## External Dependencies

- GitHub-hosted skill distribution for `alexandre-machado/ai-stuffs`.
- RouterOS devices or RouterOS-compatible test environments for `.rsc` script validation.
- Third-party token-saving tools described in `docs/best-setup-ever.md` such as RTK, Headroom, MemStack, ccusage, and Claude Monitor.

## Notes

- There is no `package.json`, `Cargo.toml`, or formal application runtime at the repo root.
- Most behavior is documented and invoked manually rather than through a build system.
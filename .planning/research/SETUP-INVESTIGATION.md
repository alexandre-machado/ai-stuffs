# Setup Investigation

## Source

- `docs/best-setup-ever.md`
- `setup.sh`
- `opencode.json`

## Key Findings

- The setup concept is a three-layer stack: RTK for shell output compression, Headroom for LLM context compression, and MemStack for persistent session memory.
- Monitoring is treated as a first-class part of the workflow through `ccusage` and `cmonitor`.
- The bootstrap script is already oriented around repeatable setup steps, but it depends heavily on remote installers and local shell conventions.
- The repository itself is not an application codebase; it is a documentation and skill package with a few helper assets.

## Open Questions

- Which of the third-party tool commands are still current and supported at the time of execution?
- Should the setup flow prioritize Bash-only compatibility or expand to zsh and other shells explicitly?
- Which steps should remain manual because they are too sensitive or environment-specific to automate safely?

## Bottom Line

The repo already has enough material to define the project clearly. The next useful work is to turn the existing guide into a safer and more repeatable setup path without pretending the external tools are owned by this repository.
# Concerns

## Summary

The repository is small and low-risk, but several areas deserve attention: external network dependence, documentation drift, and claims in the setup guide that are not verified by repo-local tests.

## Technical Debt

- The repo mixes a stable skill package with exploratory setup notes and example project folders, which can make the scope feel broader than the actual implemented surface.
- There is no repository-level automation to verify the many commands documented in `docs/best-setup-ever.md`.
- The root does not currently include a unified test or lint workflow for the markdown and shell assets.

## Reliability Risks

- `setup.sh` performs package installation, downloads remote installers, and writes shell configuration, so it should be treated as a high-privilege script.
- The setup guide references third-party tools and benefits that may change independently of this repo.
- `opencode.json` depends on a local service being available at `http://127.0.0.1:50286/v1`; if that service is absent, the config is inert.

## Security and Trust Concerns

- Remote install commands in the setup guide should be executed only after review in a controlled environment.
- The docs discuss multiple AI services and local proxies, which increases the chance of stale or incompatible configuration advice over time.
- The repo does not currently document an approval boundary for shell scripts that modify user startup files.

## Maintenance Risks

- The documentation is useful but can drift quickly because it depends on fast-moving third-party tooling.
- The token-optimization guide is long and may become outdated as tools change names, flags, or pricing models.
- If more skills are added later, the root navigation files will need to stay synchronized with the skill directories.

## Monitoring Items

- Recheck the external tool commands in `docs/best-setup-ever.md` before treating them as current operational guidance.
- Verify that any future shell automation remains idempotent and safe by default.
- Keep the skill references aligned with RouterOS release changes and linter behavior.
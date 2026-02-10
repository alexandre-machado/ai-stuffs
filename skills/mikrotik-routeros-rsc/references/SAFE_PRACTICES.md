# Best Practices: Security and Idempotency

Primary sources:
- Scripting Manual (Jan 2026): https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting
- Scripting Tips & Tricks: https://help.mikrotik.com/docs/spaces/ROS/pages/283574370/Scripting+Tips+and+Tricks

## Idempotency
- Before `add`/`set`, verify with `find where ...` and conditional `:if`.
- Use `print as-value` and arrays to compare states.
- Avoid depending on `numbers`; select by `name`, `address`, `comment`, etc.

## Permissions
- Scripts inherit permissions from user/scheduler depending on execution.
- `use-script-permissions` only works when script permissions are sufficient.
- Don't grant unnecessary policies in `/system script add policy=...`.

## Robustness
- `:onerror` to capture failures; combine with `:retry` for controlled retries.
- Limit multiple instances with `:jobname`.
- Avoid `:delay` in loops without limits; use `Scheduler` for periodic tasks.

## Security
- Don't automate destructive commands (`system reset-configuration`, formatting, wipe).
- Avoid accidental exfiltration (`/export hide-sensitive=no` in sensitive environments).
- Handle secrets carefully; don't log passwords in `:log`.
- Validate inputs before `fetch` and similar operations.

## Style
- Parameterize with `:local` at top; add `:global` only when needed.
- Short and objective comments; no large blocks.
- Use `where` and clear expressions; consistent alignment.

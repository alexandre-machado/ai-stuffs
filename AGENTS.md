# AI Stuffs Skills

A collection of specialized agent skills for various domains.

## Available Skills

### mikrotik-routeros-rsc

Create, edit, and review RouterOS scripts (.rsc) with focus on idempotence, security, and best practices. Use when you need to generate, adjust, or import .rsc files for MikroTik routers.

**Use when:**
- Creating new RouterOS configurations via script
- Editing existing scripts with safe corrections
- Reviewing execution risks and script policies
- Validating with import dry-run and error capture
- Working with MikroTik RouterOS v6+ systems

**Key features:**
- Idempotent script patterns
- Security best practices
- Syntax validation with linter
- Safe import testing (dry-run)
- Error handling patterns

**Installation:**

```bash
npx skills add alexandre-machado/ai-stuffs --skill mikrotik-routeros-rsc
```

Or from GitHub URL:

```bash
npx skills add https://github.com/alexandre-machado/ai-stuffs --skill mikrotik-routeros-rsc
```

## Skill Structure

Each skill contains:

- `SKILL.md` - Instructions for the agent
- `scripts/` - Helper scripts for automation (optional)  
- `references/` - Supporting documentation (optional)

## License

MIT

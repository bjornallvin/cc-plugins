# Claude Code Plugins

A collection of plugins and utilities for [Claude Code](https://claude.com/claude-code).

## Plugins

### secure-env

A security plugin that helps protect sensitive .env files from accidental access by Claude Code while still allowing access to .env.example files.

#### Features

- **Permission Management**: Apply secure deny rules for .env and .env.local files
- **Permission Checking**: Verify current Claude Code permissions for .env files
- **Environment Loading**: Execute bash commands with environment variables loaded from .env

#### Installation

Copy the `secure-env` directory to your Claude Code plugins location:

```bash
cp -r secure-env ~/.claude/
```

#### Commands

##### `/secure-env.check`

Check the current Claude Code permissions for .env files without attempting to read them.

This command analyzes:
- User settings (`~/.claude/settings.json`)
- Project settings (`./.claude/settings.json`)
- Local project settings (`./.claude/settings.local.json`)

It shows which settings are active and provides warnings if project settings override user-level protections.

##### `/secure-env.apply`

Apply secure .env permission deny rules to the current project's Claude settings.

This command:
- Adds deny rules for `.env` and `.env.local` files
- Adds allow rules for `.env.example` files
- Applies to both `.claude/settings.json` and `.claude/settings.local.json`
- Preserves all existing project settings (only merges the .env rules)
- Creates backups before modifying
- Creates the settings files if they don't exist

**Rules applied:**
```
DENY:
  - Read(**/.env)
  - Write(**/.env)
  - Read(**/.env.local)
  - Write(**/.env.local)

ALLOW:
  - Read(**/.env.example)
  - Write(**/.env.example)
```

##### `/secure-env.with-env`

Execute a bash command with environment variables loaded from .env.

**Usage:** `/secure-env.with-env <command>`

Example: `/secure-env.with-env echo $DATABASE_URL`

#### Scripts

- `scripts/check-env-permissions.sh` - Check .env permissions across all Claude settings files
- `scripts/apply-env-security.sh` - Apply secure .env deny rules to project-level settings

#### How It Works

Claude Code has a settings precedence system:
1. `.claude/settings.local.json` (highest precedence)
2. `.claude/settings.json` (overrides user settings)
3. `~/.claude/settings.json` (user-level settings)

This plugin ensures that .env protections are applied at the project level to prevent accidental exposure of sensitive credentials to Claude Code.

#### Best Practices

1. Run `/secure-env.check` to see current permissions
2. Run `/secure-env.apply` in each project to add protections
3. Use `.env.example` files for documentation (Claude can read these)
4. Keep actual credentials in `.env` or `.env.local` (Claude cannot read these after applying rules)

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

MIT

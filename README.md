# Claude Code Plugins

A collection of plugins and utilities for [Claude Code](https://claude.com/claude-code).

## Plugins

### dad

A plugin that delivers hilarious dad jokes on demand, powered by the icanhazdadjoke API.

**Key Features:**
- Get fresh dad jokes with a simple command
- Powered by a quality dad joke API
- Perfect for lightening the mood during coding sessions

[Read more →](./dad/README.md)

### merge-settings

A plugin for managing and merging Claude Code settings across user, project, and local configuration files.

**Key Features:**
- View all settings files and see which one is active
- Merge settings from overridden files into the active configuration
- Handle conflicts gracefully with clear reporting
- Create automatic backups before making changes

[Read more →](./merge-settings/README.md)

### secure-env

A security plugin that helps protect sensitive .env files from accidental access by Claude Code while still allowing access to .env.example files.

#### Features

- **Permission Management**: Apply secure deny rules for .env and .env.local files
- **Permission Checking**: Verify current Claude Code permissions for .env files

#### Installation

Copy the `secure-env` directory to your Claude Code plugins location:

```bash
/plugin marketplace add bjornallvin/cc-plugins
/plugin install secure-env@cc-plugins
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

#### Scripts

- `scripts/check-env-permissions.sh` - Check .env permissions across all Claude settings files
- `scripts/apply-env-security.sh` - Apply secure .env deny rules to project-level settings

#### How It Works

Claude Code has a settings precedence system:
1. `.claude/settings.local.json` (highest precedence)
2. `.claude/settings.json` (overrides user settings)
3. `~/.claude/settings.json` (user-level settings)

This plugin ensures that .env protections are applied at the project level to prevent accidental exposure of sensitive credentials to Claude Code.

#### Using .env Values Securely

Even with deny rules in place, you can still use environment variables from your `.env` file by sourcing it when running commands. This loads the variables into the shell environment without Claude reading the file directly.

**Safe approach: Source .env for application commands**

```bash
source .env && npm start
source .env && npm run migrate
source .env && docker-compose up
source .env && python manage.py runserver
```

**How it works:**
- `source .env` loads environment variables into the current shell session
- The variables become available to your application or scripts
- Claude never reads the .env file contents
- The .env file remains protected by deny rules
- **Important**: Avoid echoing or printing env var values, as that would expose them in the context

**What NOT to do:**
- ❌ Don't run commands like `echo $SECRET_KEY` or `printenv` - this exposes secrets in the output
- ❌ Don't ask Claude to help debug env var values - use `.env.example` with dummy values instead
- ✅ Do use `source .env && <command>` to run your applications that need the variables

#### Best Practices

1. Run `/secure-env.check` to see current permissions
2. Run `/secure-env.apply` in each project to add protections
3. Use `.env.example` files for documentation (Claude can read these)
4. Keep actual credentials in `.env` or `.env.local` (Claude cannot read these after applying rules)
5. Use `source .env && <command>` to run applications that need environment variables
6. Never echo or print env var values in commands - this exposes them to Claude's context

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

MIT

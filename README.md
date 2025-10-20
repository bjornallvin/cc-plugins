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

#### Accessing .env Values Without Reading the File

Even with deny rules in place, you can still use environment variables from your `.env` file by sourcing it in your shell. This loads the variables into the environment without Claude needing to read the file directly.

**Method 1: Use the `/secure-env.with-env` command**

The easiest way is to use the built-in command:

```bash
/secure-env.with-env echo $DATABASE_URL
```

This command uses `source .env && <your-command>` behind the scenes, making environment variables available to the command without exposing the file contents to Claude.

**Method 2: Manual sourcing in bash commands**

You can also manually source the .env file when running bash commands:

```bash
source .env && npm run migrate
source .env && docker-compose up
source .env && python manage.py runserver
```

**How it works:**
- `source .env` loads all environment variables into the current shell session
- The variables become available to any subsequent commands in that session
- Claude never sees the actual file contents, only the command output
- The .env file remains protected by the deny rules

**Example workflow:**

1. Apply protections: `/secure-env.apply`
2. Source and run commands: `/secure-env.with-env npm start`
3. Environment variables are available to your application
4. Claude can see command output but not the .env file itself

#### Best Practices

1. Run `/secure-env.check` to see current permissions
2. Run `/secure-env.apply` in each project to add protections
3. Use `.env.example` files for documentation (Claude can read these)
4. Keep actual credentials in `.env` or `.env.local` (Claude cannot read these after applying rules)
5. Use `/secure-env.with-env` or `source .env && <command>` to access environment variables when needed

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

MIT

# claude-settings

A Claude Code plugin for managing and merging settings across user, project, and local configuration files.

## Overview

Claude Code has a settings precedence system where higher-level settings completely override lower-level ones (no automatic merging). This plugin helps you understand which settings are active and merge settings from overridden files when needed.

**Settings file precedence:**
1. `./.claude/settings.local.json` (highest - overrides everything)
2. `./.claude/settings.json` (overrides user settings)
3. `~/.claude/settings.json` (lowest - user-level defaults)

## Features

- **Settings Inspection**: View all settings files and see which one is currently active
- **Merge Capabilities**: Merge settings "upwards" from overridden files into the active file
- **Conflict Detection**: Identify and handle conflicting settings gracefully
- **Safe Operations**: Creates backups before making changes

## Installation

Copy the `claude-settings` directory to your Claude Code plugins location:

```bash
/plugin marketplace add bjornallvin/cc-plugins
/plugin install claude-settings@cc-plugins
```

## Commands

### `/claude-settings.analyze`

Check all Claude settings files and show their contents with clear indication of which file is active.

**What it shows:**
- All three settings file locations and their contents
- Which settings file is currently active (based on precedence)
- What settings are being overridden and ignored
- Summary of permissions, hooks, and other configuration in each file

**Example output:**
```
[USER] ~/.claude/settings.json
  - permissions: 4 allow rules, 2 deny rules
  - hooks: 1 hook configured

[PROJECT] ./.claude/settings.json
  - File not found

[LOCAL] ./.claude/settings.local.json
  - File not found

=== ACTIVE SETTINGS ===
⚡ User settings are ACTIVE
   File: ~/.claude/settings.json

💡 TIP: Run '/claude-settings.merge' to merge settings from overridden files.
```

### `/claude-settings.merge`

Merge settings from overridden (lower-precedence) files into the active settings file.

**How it works:**
- Combines `permissions.allow` and `permissions.deny` arrays (removes duplicates)
- Merges `hooks` (active file's values win on conflicts)
- Merges other settings (active file's values win on conflicts)
- Creates a timestamped backup before making changes
- Shows preview and requests confirmation before applying

**Merge strategy:**

| Setting Type | Behavior |
|--------------|----------|
| `permissions.allow` / `permissions.deny` | Combine all unique patterns from all files |
| `hooks` | Add new hooks; keep active file's value on conflicts |
| Other keys | Add new keys; keep active file's value on conflicts |

**Example output:**
```
Found overridden files:
  - ~/.claude/settings.json (2 permissions, 1 hook)

Active file: ./.claude/settings.local.json

Merge preview:
  ✓ Adding 2 new deny patterns
  ✓ Adding hook: sessionStart
  ⚠️  Conflict: hook 'userPromptSubmit' exists in both (keeping active file's value)

Create backup? Creating: ./.claude/settings.local.json.backup-20251021-113000

Apply merge? [Waiting for confirmation...]

✅ Merged successfully!
   - Added 2 permission patterns
   - Added 1 hook
   - Resolved 1 conflict (kept active file's value)

💡 Run '/claude-settings.analyze' to verify the merged settings.
```

## Use Cases

### Scenario 1: Project overrides your user settings

You have secure deny rules in `~/.claude/settings.json`, but a project has `./.claude/settings.json` that doesn't include those protections.

**Solution:**
1. Run `/claude-settings.analyze` to see what's being overridden
2. Run `/claude-settings.merge` to copy your user-level protections into the project settings

### Scenario 2: Local override without losing project config

You created `./.claude/settings.local.json` for temporary local testing, but you want to preserve the project settings from `./.claude/settings.json`.

**Solution:**
1. Run `/claude-settings.analyze` to see both files
2. Run `/claude-settings.merge` to merge project settings into your local file

### Scenario 3: Understanding which settings are active

You're not sure which configuration file is controlling Claude's behavior.

**Solution:**
Run `/claude-settings.analyze` to see all files and which one is active

## How Settings Precedence Works

When multiple settings files exist, Claude Code uses **complete override** (not merging):

- If `./.claude/settings.local.json` exists, it's the **only** file used
- Else if `./.claude/settings.json` exists, it's the **only** file used
- Else `~/.claude/settings.json` is used

This means:
- ❌ Settings are NOT merged automatically
- ❌ You can lose important user-level settings if project settings exist
- ✅ This plugin helps you merge manually when needed

## Best Practices

1. **Before starting work on a new project:**
   - Run `/claude-settings.analyze` to see if project settings exist
   - Run `/claude-settings.merge` if you want to preserve your user-level settings

2. **When creating project settings:**
   - Start by running `/claude-settings.analyze` to see your user settings
   - Create project settings, then run `/claude-settings.merge` to include user defaults

3. **When collaborating:**
   - Share `./.claude/settings.json` with your team (commit to git)
   - Keep `./.claude/settings.local.json` in `.gitignore` for personal overrides
   - Use `/claude-settings.merge` to sync team settings into your local overrides

4. **Regular maintenance:**
   - Periodically run `/claude-settings.analyze` to ensure expected settings are active
   - Check for overridden settings that you might want to merge

## Safety Features

- **Backups**: Automatically creates timestamped backups before modifying files
- **Preview**: Shows exactly what will be merged before applying changes
- **Confirmation**: Requires user approval before writing changes
- **Conflict reporting**: Clearly shows when settings conflict and which value wins
- **Read-only check**: The check command never modifies files

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

MIT

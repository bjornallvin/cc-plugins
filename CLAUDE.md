# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Reference Documentation**: See `docs/claude-code-plugins-reference.md` for detailed information about the Claude Code plugin system, including manifest schemas, marketplace distribution, and all supported component types.

## Overview

This is a collection of Claude Code plugins distributed via marketplace. The repository contains three plugins:
- `claude-settings`: Manages Claude settings across user/project/local scopes with merge capabilities
- `notifications`: Provides audio and popup notifications for Claude events
- `secure-env`: Protects .env files from accidental access by Claude Code

## Architecture

### Plugin Structure

Each plugin follows the Claude Code plugin convention with some custom implementation choices:

```
<plugin-name>/
  .claude-plugin/
    plugin.json         # Plugin metadata (name, version, description, author)
                        # Contains "commands" array listing relative paths to command files
  commands/
    *.md                # Slash command definitions (plain markdown, no YAML frontmatter)
  scripts/
    *.sh                # Bash scripts for implementation (not standard, specific to this repo)
  README.md             # User-facing documentation
```

**Implementation approach**: These plugins use two different patterns for commands:
1. **Script delegation**: Commands that invoke bash scripts (e.g., `claude-settings.check` runs `check-settings.sh`)
2. **Instruction-based**: Commands that provide detailed instructions for Claude to follow directly (e.g., `secure-env.check`)

**Note**: The `scripts/` directory is a custom implementation detail for this repository. Standard Claude Code plugins can implement logic entirely within command markdown or use agents/skills.

### Marketplace Distribution

The root `.claude-plugin/marketplace.json` defines the marketplace configuration:
- Lists all plugins with `name`, `source`, and `description`
- Includes marketplace metadata: `name`, `owner` (name, email), `plugins` array

Users install via:
```bash
/plugin marketplace add bjornallvin/cc-plugins
/plugin install <plugin-name>@cc-plugins
```

### Command Files

Commands are referenced in `plugin.json` via the `commands` array pointing to markdown files. Two implementation patterns used:

**Pattern 1: Bash script invocation** (claude-settings)
```markdown
Check all Claude settings files...

Run the check-settings script:
bash ~/.claude/plugins/claude-settings/scripts/check-settings.sh
```

**Pattern 2: Direct instructions** (secure-env)
```markdown
Check the current Claude Code permissions for .env files...

1. Check all three settings locations:
   - **User settings**: `~/.claude/settings.json`
   ...
```

## Settings File Precedence

Both plugins work with Claude Code's settings precedence system:
1. `./.claude/settings.local.json` (highest - overrides everything)
2. `./.claude/settings.json` (overrides user settings)
3. `~/.claude/settings.json` (user-level defaults)

Higher-level files **completely override** lower-level ones (no automatic merging).

## Plugin Details

### claude-settings

Allows users to:
- View all settings files with `/claude-settings.analyze`
- Merge overridden settings upward into active file with `/claude-settings.merge`
- Handle conflicts (active file wins)
- Create backups before modifications

### notifications

Provides audio and popup notifications for Claude events:
- `/notifications.check` - Check status of notification hooks
- `/notifications.install` - Install hooks to project `.claude/` directory
- `/notifications.remove` - Remove notification hooks from project

Uses Claude Code hooks system to trigger notifications:
- `Notification` hook: Triggered when Claude sends notifications or requests permissions (waiting for input)
- `Stop` hook: Runs when main agent finishes responding (task completed)

Audio files remain in plugin directory and are referenced by hooks. Supports macOS (afplay/osascript) and Linux (notify-send).

### secure-env

Manages .env file permissions to prevent Claude from reading sensitive credentials:
- `/secure-env.check` - Shows current .env permissions across all settings
- `/secure-env.apply` - Applies deny rules for .env files, allow rules for .env.example

The scripts use `jq` for JSON parsing and provide formatted output with emojis and box-drawing characters.

## Standard Plugin Components (Not Yet Used)

Claude Code plugins support additional components not currently used in this repository:

- **Agents** (`agents/` directory): Specialized subagents for autonomous task handling
- **Skills** (`skills/` directory with `SKILL.md` files): Model-invoked capabilities that Claude autonomously deploys
- **Hooks** (`hooks/hooks.json`): Event handlers responding to system events (e.g., `SessionStart`, `PostToolUse`)
- **MCP Servers** (`.mcp.json`): External tool integrations

These could be leveraged in future development to provide richer plugin functionality.

## Development Workflow

This is a bash-based project with no build/test/lint systems. To work on plugins:

1. **Edit commands**: Modify markdown files in `commands/` or bash scripts in `scripts/`
2. **Test locally**: Install marketplace locally with `/plugin marketplace add ./`
3. **Test commands**: Run `/plugin install <plugin-name>` and test slash commands
4. **Test scripts**: Can also run bash scripts directly for debugging
5. **Commit**: Use conventional commit messages

## Important Notes

- Scripts assume `jq` is available but gracefully degrade if missing
- Bash scripts use absolute paths (`~/.claude/`) or environment variables for portability
- Backup files use timestamp format: `filename.backup-YYYYMMDD-HHMMSS`
- Scripts output to stdout/stderr with formatted output (emojis, box-drawing characters)
- No logging system - all output is immediate to terminal

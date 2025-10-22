# Claude Code Plugins Reference

This document contains relevant documentation about the Claude Code plugin system, extracted from the official documentation at https://docs.claude.com/en/docs/claude-code/.

Last updated: 2025-10-22

## Plugin Structure Overview

Plugins follow a hierarchical directory organization:

```
plugin-root/
├── .claude-plugin/
│   └── plugin.json          # Metadata configuration
├── commands/                 # Slash commands (optional)
├── agents/                   # Agent definitions (optional)
├── skills/                   # Agent capabilities (optional)
├── hooks/                    # Event handlers (optional)
└── .mcp.json                # External integrations (optional)
```

## Plugin Manifest (plugin.json)

Located in `.claude-plugin/plugin.json`, this file contains essential metadata.

### Required Fields

- **name**: Unique kebab-case identifier for the plugin
- **version**: Semantic versioning designation
- **description**: Purpose and functionality overview
- **author**: Creator information with name field

### Optional Fields

- **homepage**: URL to plugin homepage
- **repository**: Source code repository URL
- **license**: License identifier
- **keywords**: Array of search terms

### Component Paths

- **commands**: String or array pointing to command files (relative paths)
- **agents**: Directory containing agent definitions
- **hooks**: Path to hook configuration
- **mcpServers**: MCP server configuration

### Example plugin.json

```json
{
  "name": "example-plugin",
  "version": "1.0.0",
  "description": "Brief functionality summary",
  "author": {
    "name": "Creator Name",
    "email": "creator@example.com"
  },
  "commands": [
    "./commands/check.md",
    "./commands/apply.md"
  ]
}
```

## Plugin Components

Claude Code supports five component types:

### 1. Commands

Custom slash commands defined in markdown files in the `commands/` directory.

**Standard format** (with YAML frontmatter):
```markdown
---
description: What the command accomplishes
---
# Command Title
Detailed instructions for Claude execution
```

**Alternative format** (plain markdown):
Commands can also be plain markdown without frontmatter, containing instructions for Claude to follow.

### 2. Agents

Specialized subagents in `agents/` directory for task-specific automation. Agents handle complex, multi-step tasks autonomously.

### 3. Skills

Model-invoked capabilities in `skills/` directory (with `SKILL.md` files) that Claude autonomously deploys based on context. Skills are automatically integrated into Claude's workflow.

### 4. Hooks

Event handlers via `hooks/hooks.json` responding to system events:
- `SessionStart`: Triggered when a new session begins
- `PostToolUse`: Triggered after tool execution
- Other event types

### 5. MCP Servers

External tool integrations defined in `.mcp.json` for connecting to Model Context Protocol servers.

## Marketplace Distribution

### Marketplace File (marketplace.json)

Located at the root `.claude-plugin/marketplace.json`:

```json
{
  "name": "marketplace-name",
  "description": "Marketplace description",
  "version": "1.0.0",
  "owner": {
    "name": "Owner Name",
    "email": "owner@example.com"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugin-directory",
      "description": "Plugin description",
      "version": "1.0.0",
      "author": { "name": "Author Name" },
      "homepage": "https://example.com",
      "repository": "https://github.com/user/repo",
      "license": "MIT",
      "keywords": ["keyword1", "keyword2"]
    }
  ]
}
```

### Required Fields

- **name**: Kebab-case marketplace identifier
- **owner**: Object with maintainer information (name, email)
- **plugins**: Array of plugin entries

### Plugin Entry Fields

Each plugin must have:
- **name**: Kebab-case identifier
- **source**: Path or URL where to fetch the plugin

Optional but recommended:
- **description**, **version**, **author**, **homepage**, **repository**, **license**, **keywords**

### Installation Methods

Users can add marketplaces through several approaches:

```bash
# GitHub repository
/plugin marketplace add owner/repo

# Git URL
/plugin marketplace add https://gitlab.com/company/plugins.git

# Local directory
/plugin marketplace add ./my-marketplace

# Direct file path
/plugin marketplace add ./path/to/marketplace.json
```

Once marketplace is added, install plugins with:
```bash
/plugin install plugin-name@marketplace-name
```

### Distribution Strategies

- **GitHub**: Recommended hosting with built-in version control
- **GitLab/Gitea**: Alternative git services work equally well
- **Local development**: Test with `/plugin marketplace add ./my-local-marketplace`
- **Team distribution**: Configure in `.claude/settings.json` under `extraKnownMarketplaces`

## Settings File System

Claude Code has a settings precedence system:

1. `./.claude/settings.local.json` (highest precedence - overrides everything)
2. `./.claude/settings.json` (overrides user settings)
3. `~/.claude/settings.json` (user-level defaults)

**Important**: Higher-level files **completely override** lower-level ones (no automatic merging).

### Team Plugin Distribution

Teams can configure automatic marketplace installation in `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": [
    "owner/repo",
    "https://gitlab.com/company/plugins.git"
  ]
}
```

When team members trust the folder, plugins install automatically.

## Plugin Activation

- **Installation**: Plugins discovered through marketplaces require Claude Code restart to activate
- **Commands**: Become accessible as slash commands (e.g., `/command-name`)
- **Agents/Skills**: Automatically integrated based on task context
- **Hooks**: Execute on configured events

## Path Portability

**Critical**: Use relative paths starting with `./` and the `${CLAUDE_PLUGIN_ROOT}` environment variable for portability across installations.

Example in command markdown:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/my-script.sh
```

Or for installed plugins:
```bash
bash ~/.claude/plugins/plugin-name/scripts/my-script.sh
```

## Command Implementation Patterns

### Pattern 1: Script Delegation

Command invokes external bash/python scripts:

```markdown
Run the script to perform the action:

bash ~/.claude/plugins/my-plugin/scripts/action.sh
```

### Pattern 2: Direct Instructions

Command provides detailed instructions for Claude to follow:

```markdown
Perform the following steps:

1. Read the configuration file at `~/.claude/settings.json`
2. Parse the JSON and extract the permissions section
3. Report the findings to the user
4. Suggest next steps if needed
```

### Pattern 3: Agent/Skill Integration

Commands can leverage agents or skills for complex workflows, though this requires separate agent/skill definitions in those directories.

## Best Practices

- Use semantic versioning for plugins and marketplaces
- Provide clear descriptions for discoverability
- Include keywords for search optimization
- Use relative paths for portability
- Create backups before modifying user files
- Provide clear output and error messages
- Document commands in plugin README
- Test locally before publishing to marketplace
- Keep plugin.json metadata up to date

## Related Documentation

For more details, see:
- https://docs.claude.com/en/docs/claude-code/plugins.md
- https://docs.claude.com/en/docs/claude-code/plugin-marketplaces.md
- https://docs.claude.com/en/docs/claude-code/plugins-reference.md
- https://docs.claude.com/en/docs/claude-code/slash-commands.md
- https://docs.claude.com/en/docs/claude-code/settings.md

# notifications

A Claude Code plugin for managing audio and popup notifications when Claude is waiting for input or completes tasks.

## Overview

This plugin helps you stay informed about Claude's status without constantly watching the terminal. It provides configurable notifications for:
- When Claude finishes responding and is waiting for your input
- When Claude completes a task or tool execution

## Features

- **Audio Notifications**: Play custom sound files for different events
- **Popup Notifications**: System notifications on macOS and Linux
- **Easy Management**: Simple commands to check, install, and remove hooks
- **Customizable**: Use your own audio files
- **Cross-Platform**: Works on macOS (via `afplay` and `osascript`) and Linux (via `notify-send`)

## Installation

```bash
/plugin marketplace add bjornallvin/cc-plugins
/plugin install notifications@cc-plugins
```

## Commands

### `/notifications.check`

Check the status of notification hooks at both project and user levels.

**What it shows:**
- Project level: `./.claude/` directory status
- User level: `~/.claude/` directory status
- Whether hooks are installed at each level
- Settings.json hook configuration for both levels
- Installation status and suggestions

**Example output:**
```
🔔 Claude Code Notification Hooks Status

═══════════════════════════════════════════════════════════════════
📂 PROJECT Level: ./.claude
═══════════════════════════════════════════════════════════════════

📁 Hooks directory: ./.claude/hooks

✅ Waiting-for-input hook installed
   File: ./.claude/hooks/waiting-for-input.sh

✅ Task-completed hook installed
   File: ./.claude/hooks/task-completed.sh

📝 Settings file: ./.claude/settings.json
   Hooks configured:
   - Notification: bash ./.claude/hooks/waiting-for-input.sh
   - Stop: bash ./.claude/hooks/task-completed.sh

Status: ✅ All hooks installed at PROJECT level

═══════════════════════════════════════════════════════════════════
📂 USER Level: /Users/username/.claude
═══════════════════════════════════════════════════════════════════

❌ No .claude directory found

Status: ❌ No hooks installed at USER level
```

### `/notifications.install`

Install notification hooks at either project or user level.

**Installation options:**
- **Project level** (`./.claude/`) - Hooks only for this project
- **User level** (`~/.claude/`) - Hooks for all projects

**What it does:**
- Prompts you to choose installation level
- Creates hooks directory if needed
- Copies hook scripts from plugin to chosen location
- Updates settings.json with hook configuration
- Creates backup of settings before modifying

**Hook events:**
- `Notification`: Triggered when Claude sends notifications or requests permissions (waiting for input)
- `Stop`: Runs when the main agent finishes responding (task completed)

### `/notifications.remove`

Remove notification hooks from project or user level.

**Removal options:**
- **Project level** (`./.claude/`) - Remove from this project only
- **User level** (`~/.claude/`) - Remove from all projects

**What it does:**
- Prompts you to choose removal level
- Removes hook scripts from chosen location
- Removes hook configuration from settings.json
- Creates backup before modifying settings
- Reports what was removed

## Custom Audio Files

By default, the hooks will show popup notifications. To add audio notifications:

1. Create or download notification sound files (MP3 recommended)
2. Place them in the plugin's `audio/` directory:
   - `~/.claude/plugins/marketplaces/cc-plugins/notifications/audio/notification.mp3`
   - `~/.claude/plugins/marketplaces/cc-plugins/notifications/audio/done.mp3`

See `audio/README.md` for more details and recommendations.

## How It Works

The plugin uses Claude Code's hook system to trigger notifications:

1. **Hook Scripts**: Bash scripts that run on specific events
2. **Audio Playback**: Uses `afplay` (macOS) to play sound files
3. **System Notifications**: Uses `osascript` (macOS) or `notify-send` (Linux) for popups
4. **Configuration**: Hooks are registered in `.claude/settings.json`

## Hook Details

### waiting-for-input.sh

Triggered when Claude sends notifications or requests permissions (waiting for user input).

- **Event**: `Notification`
- **Notification**: "Claude is waiting for your input"
- **Audio**: `audio/notification.mp3` (if exists)

### task-completed.sh

Runs when the main agent finishes responding (task completed).

- **Event**: `Stop`
- **Notification**: "Task completed"
- **Audio**: `audio/done.mp3` (if exists)

## Platform Support

### macOS
- ✅ Audio notifications via `afplay`
- ✅ Popup notifications via `osascript`
- ✅ Built-in system sounds as fallback

### Linux
- ✅ Popup notifications via `notify-send`
- ⚠️ Audio requires additional setup (install audio player)

## Troubleshooting

### No audio playing
- Check if audio files exist in the plugin's `audio/` directory
- Verify files are named correctly (`waiting.mp3`, `completed.mp3`)
- On macOS, verify `afplay` is available: `which afplay`
- Check file permissions: `ls -l ~/.claude/plugins/marketplaces/cc-plugins/notifications/audio/`

### No popup notifications
- **macOS**: Verify `osascript` is available: `which osascript`
- **Linux**: Install notify-send: `sudo apt install libnotify-bin`
- Check system notification settings

### Hooks not triggering
- Run `/notifications.check` to verify installation
- Check that hooks are configured in `.claude/settings.json`
- Verify hook scripts are executable: `ls -l .claude/hooks/`
- Check for errors in hook execution (run manually to test)

## Best Practices

1. **Test before committing**: Install and test hooks before adding to project
2. **Custom sounds**: Use short, pleasant sounds (0.5-2 seconds)
3. **Volume control**: Test audio volume before using
4. **Team settings**: Consider if all team members want notifications
5. **Per-project**: Install hooks per-project basis for flexibility

## Safety Features

- **Backups**: Automatically creates timestamped backups before modifying settings
- **Non-destructive**: Install/remove doesn't affect other settings
- **Graceful degradation**: Works with or without audio files
- **Error handling**: Scripts handle missing dependencies gracefully

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

MIT

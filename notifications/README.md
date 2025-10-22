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

Check the status of notification hooks in the current project.

**What it shows:**
- Whether hooks directory exists
- Which notification hooks are installed
- Settings.json hook configuration
- Installation status and suggestions

**Example output:**
```
🔔 Claude Code Notification Hooks Status

📁 Hooks directory: ./.claude/hooks

✅ Waiting-for-input hook installed
   File: ./.claude/hooks/waiting-for-input.sh

✅ Task-completed hook installed
   File: ./.claude/hooks/task-completed.sh

📝 Settings file: ./.claude/settings.json
   Hooks configured in settings.json
   - Notification: bash ./.claude/hooks/waiting-for-input.sh
   - Stop: bash ./.claude/hooks/task-completed.sh

✅ All notification hooks are installed
```

### `/notifications.install`

Install notification hooks to the current project's `.claude/` directory.

**What it does:**
- Creates `.claude/hooks/` directory if needed
- Copies hook scripts from plugin to project
- Updates `.claude/settings.json` with hook configuration
- Creates backup of settings before modifying

**Hook events:**
- `Notification`: Triggered when Claude sends notifications or requests permissions (waiting for input)
- `Stop`: Runs when the main agent finishes responding (task completed)

### `/notifications.remove`

Remove notification hooks from the current project.

**What it does:**
- Removes hook scripts from `.claude/hooks/`
- Removes hook configuration from settings.json
- Creates backup before modifying settings
- Reports what was removed

## Custom Audio Files

By default, the hooks will show popup notifications. To add audio notifications:

1. Create or download notification sound files (MP3 recommended)
2. Place them in the plugin's `audio/` directory:
   - `~/.claude/plugins/marketplaces/cc-plugins/notifications/audio/waiting.mp3`
   - `~/.claude/plugins/marketplaces/cc-plugins/notifications/audio/completed.mp3`

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
- **Audio**: `audio/waiting.mp3` (if exists)

### task-completed.sh

Runs when the main agent finishes responding (task completed).

- **Event**: `Stop`
- **Notification**: "Task completed"
- **Audio**: `audio/completed.mp3` (if exists)

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

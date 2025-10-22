#!/bin/bash

# Hook: Notification when Claude completes a task
# Event: Stop - Runs when the main agent finishes responding

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/marketplaces/cc-plugins/notifications}"
AUDIO_FILE="$PLUGIN_ROOT/audio/done.mp3"

# Play audio notification (macOS)
if command -v afplay &> /dev/null && [ -f "$AUDIO_FILE" ]; then
    afplay "$AUDIO_FILE" &
fi

# Show popup notification (macOS)
if command -v osascript &> /dev/null; then
    osascript -e 'display notification "Task completed" with title "Claude Code" sound name "Tink"' &> /dev/null &
fi

# For Linux (alternative)
if command -v notify-send &> /dev/null; then
    notify-send "Claude Code" "Task completed" &> /dev/null &
fi

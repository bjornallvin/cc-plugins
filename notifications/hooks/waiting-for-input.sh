#!/bin/bash

# Hook: Notification when Claude is waiting for input
# Event: Notification - Triggered when Claude sends notifications or requests permissions

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/marketplaces/cc-plugins/notifications}"
AUDIO_FILE="$PLUGIN_ROOT/audio/notification.mp3"

# Play audio notification (macOS)
if command -v afplay &> /dev/null && [ -f "$AUDIO_FILE" ]; then
    afplay "$AUDIO_FILE" &
fi

# Show popup notification (macOS)
if command -v osascript &> /dev/null; then
    osascript -e 'display notification "Claude is waiting for your input" with title "Claude Code" sound name "Glass"' &> /dev/null &
fi

# For Linux (alternative)
if command -v notify-send &> /dev/null; then
    notify-send "Claude Code" "Claude is waiting for your input" &> /dev/null &
fi

#!/bin/bash

# Remove notification hooks from project or user level
# Usage:
#   remove-notifications.sh user
#   remove-notifications.sh project [settings|local]

REMOVE_LEVEL="$1"
SETTINGS_TYPE="$2"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔕 Removing Claude Code Notification Hooks"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Validate and set target based on argument
case "$REMOVE_LEVEL" in
    project)
        TARGET_CLAUDE="./.claude"

        # Determine which settings file to use
        case "$SETTINGS_TYPE" in
            settings)
                SETTINGS_FILE="$TARGET_CLAUDE/settings.json"
                echo "Removing from project level: $TARGET_CLAUDE"
                echo "Using: settings.json (committed to git)"
                ;;
            local)
                SETTINGS_FILE="$TARGET_CLAUDE/settings.local.json"
                echo "Removing from project level: $TARGET_CLAUDE"
                echo "Using: settings.local.json (local only, not committed)"
                ;;
            *)
                echo "❌ Invalid settings type for project level: '$SETTINGS_TYPE'"
                echo ""
                echo "Usage: $0 project [settings|local]"
                echo "  settings - Use settings.json (committed to git)"
                echo "  local    - Use settings.local.json (local only)"
                exit 1
                ;;
        esac
        ;;
    user)
        TARGET_CLAUDE="$HOME/.claude"
        SETTINGS_FILE="$TARGET_CLAUDE/settings.json"
        echo "Removing from user level: $TARGET_CLAUDE"
        ;;
    *)
        echo "❌ Invalid removal level: '$REMOVE_LEVEL'"
        echo ""
        echo "Usage:"
        echo "  $0 user"
        echo "  $0 project [settings|local]"
        echo ""
        echo "Levels:"
        echo "  project - Remove hooks from project level (./.claude/)"
        echo "  user    - Remove hooks from user level (~/.claude/)"
        exit 1
        ;;
esac

echo ""

# Update settings file to remove hook configuration
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "ℹ️  No settings file found: $SETTINGS_FILE"
    echo "   Nothing to remove"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ No notification hooks were configured at $REMOVE_LEVEL level"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    exit 0
fi

echo "⚙️  Updating settings file..."

# Create backup
BACKUP_FILE="${SETTINGS_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$SETTINGS_FILE" "$BACKUP_FILE"
echo "   ✓ Backup created: $BACKUP_FILE"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "   ⚠️  jq not installed - cannot auto-update settings file"
    echo "   Please manually remove these hooks from $SETTINGS_FILE:"
    echo "     - hooks.Notification"
    echo "     - hooks.Stop"
    echo ""
else
    # Check if hooks exist in the file
    HAS_NOTIFICATION=$(jq -r '.hooks.Notification // empty' "$SETTINGS_FILE" 2>/dev/null)
    HAS_STOP=$(jq -r '.hooks.Stop // empty' "$SETTINGS_FILE" 2>/dev/null)

    if [ -z "$HAS_NOTIFICATION" ] && [ -z "$HAS_STOP" ]; then
        echo "   ℹ️  No notification hooks found in $SETTINGS_FILE"
    else
        # Use jq to remove only notification hook entries
        TEMP_FILE=$(mktemp)
        jq 'del(.hooks.Notification) | del(.hooks.Stop)' \
            "$SETTINGS_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$SETTINGS_FILE"
        echo "   ✓ Removed notification hooks from $SETTINGS_FILE"
        echo "   ℹ️  All other settings preserved"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Notification hooks removed successfully from $REMOVE_LEVEL level!"
echo ""
echo "Updated: $SETTINGS_FILE"
echo ""
echo "💡 TIP: Run '/notifications.check' to verify removal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

#!/bin/bash

# Remove notification hooks from project or user level
# Usage: remove-notifications.sh [project|user]

REMOVE_LEVEL="$1"

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
        TARGET_HOOKS="$TARGET_CLAUDE/hooks"
        SETTINGS_FILE="$TARGET_CLAUDE/settings.json"
        echo "Removing from project level: $TARGET_CLAUDE"
        ;;
    user)
        TARGET_CLAUDE="$HOME/.claude"
        TARGET_HOOKS="$TARGET_CLAUDE/hooks"
        SETTINGS_FILE="$TARGET_CLAUDE/settings.json"
        echo "Removing from user level: $TARGET_CLAUDE"
        ;;
    *)
        echo "❌ Invalid removal level: '$REMOVE_LEVEL'"
        echo ""
        echo "Usage: $0 [project|user]"
        echo "  project - Remove hooks from project level (./.claude/)"
        echo "  user    - Remove hooks from user level (~/.claude/)"
        exit 1
        ;;
esac

echo ""

WAITING_HOOK="$TARGET_HOOKS/waiting-for-input.sh"
COMPLETED_HOOK="$TARGET_HOOKS/task-completed.sh"

REMOVED_COUNT=0

# Remove hook scripts
echo "🗑️  Removing hook scripts..."

if [ -f "$WAITING_HOOK" ]; then
    rm "$WAITING_HOOK"
    echo "   ✓ Removed: waiting-for-input.sh"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
else
    echo "   ⚠️  Not found: waiting-for-input.sh"
fi

if [ -f "$COMPLETED_HOOK" ]; then
    rm "$COMPLETED_HOOK"
    echo "   ✓ Removed: task-completed.sh"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
else
    echo "   ⚠️  Not found: task-completed.sh"
fi

echo ""

# Update settings.json to remove hook configuration
if [ -f "$SETTINGS_FILE" ]; then
    echo "⚙️  Updating settings.json..."

    # Create backup
    BACKUP_FILE="${SETTINGS_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "   ✓ Backup created: $BACKUP_FILE"

    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "   ⚠️  jq not installed - cannot auto-update settings.json"
        echo "   Please manually remove these hooks from $SETTINGS_FILE:"
        echo "     - Notification"
        echo "     - Stop"
        echo ""
    else
        # Use jq to remove hook entries
        TEMP_FILE=$(mktemp)
        jq 'del(.hooks.Notification) | del(.hooks.Stop)' \
            "$SETTINGS_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$SETTINGS_FILE"
        echo "   ✓ Removed hooks from settings.json"
    fi
else
    echo "ℹ️  No settings file found: $SETTINGS_FILE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $REMOVED_COUNT -eq 0 ]; then
    echo "ℹ️  No notification hooks were installed at $REMOVE_LEVEL level"
else
    echo "✅ Notification hooks removed successfully from $REMOVE_LEVEL level!"
    echo ""
    echo "Removed $REMOVED_COUNT hook script(s)"
fi

echo ""
echo "💡 TIP: Run '/notifications.check' to verify removal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

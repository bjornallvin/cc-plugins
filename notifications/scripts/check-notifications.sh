#!/bin/bash

# Check notification hooks status in the current project

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔔 Claude Code Notification Hooks Status"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

HOOKS_DIR="./.claude/hooks"
SETTINGS_FILE="./.claude/settings.json"

# Check if .claude directory exists
if [ ! -d "./.claude" ]; then
    echo "❌ No .claude directory found in current project"
    echo "   Notification hooks are not installed"
    echo ""
    echo "💡 TIP: Run '/notifications.install' to install notification hooks"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    exit 0
fi

# Check if hooks directory exists
if [ ! -d "$HOOKS_DIR" ]; then
    echo "❌ No hooks directory found: $HOOKS_DIR"
    echo "   Notification hooks are not installed"
    echo ""
    echo "💡 TIP: Run '/notifications.install' to install notification hooks"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    exit 0
fi

echo "📁 Hooks directory: $HOOKS_DIR"
echo ""

# Check for specific notification hooks
WAITING_HOOK="$HOOKS_DIR/waiting-for-input.sh"
COMPLETED_HOOK="$HOOKS_DIR/task-completed.sh"

INSTALLED_COUNT=0

if [ -f "$WAITING_HOOK" ]; then
    echo "✅ Waiting-for-input hook installed"
    echo "   File: $WAITING_HOOK"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
else
    echo "❌ Waiting-for-input hook not found"
fi

echo ""

if [ -f "$COMPLETED_HOOK" ]; then
    echo "✅ Task-completed hook installed"
    echo "   File: $COMPLETED_HOOK"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
else
    echo "❌ Task-completed hook not found"
fi

echo ""

# Check settings.json for hook configuration
if [ -f "$SETTINGS_FILE" ]; then
    echo "📝 Settings file: $SETTINGS_FILE"

    if command -v jq &> /dev/null; then
        HOOKS_CONFIG=$(jq -r '.hooks // empty' "$SETTINGS_FILE" 2>/dev/null)
        if [ -n "$HOOKS_CONFIG" ] && [ "$HOOKS_CONFIG" != "null" ]; then
            echo "   Hooks configured in settings.json"
            jq -r '.hooks | to_entries[] | "   - \(.key): \(.value)"' "$SETTINGS_FILE" 2>/dev/null
        else
            echo "   No hooks configured in settings.json"
        fi
    else
        echo "   (jq not available - cannot parse settings)"
    fi
else
    echo "⚠️  No settings file found: $SETTINGS_FILE"
    echo "   Hooks may not be active"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $INSTALLED_COUNT -eq 0 ]; then
    echo "💡 TIP: Run '/notifications.install' to install notification hooks"
elif [ $INSTALLED_COUNT -lt 2 ]; then
    echo "⚠️  WARNING: Only $INSTALLED_COUNT of 2 hooks installed"
    echo "💡 TIP: Run '/notifications.install' to install all hooks"
else
    echo "✅ All notification hooks are installed"
    echo "💡 TIP: Run '/notifications.remove' to uninstall hooks"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

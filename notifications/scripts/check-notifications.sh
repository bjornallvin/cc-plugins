#!/bin/bash

# Check notification hooks status at both project and user level

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔔 Claude Code Notification Hooks Status"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to check hooks at a specific location
check_hooks_at_location() {
    local LEVEL="$1"
    local CLAUDE_DIR="$2"
    local HOOKS_DIR="$CLAUDE_DIR/hooks"
    local SETTINGS_FILE="$CLAUDE_DIR/settings.json"

    echo "═══════════════════════════════════════════════════════════════════"
    echo "📂 $LEVEL Level: $CLAUDE_DIR"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""

    # Check if .claude directory exists
    if [ ! -d "$CLAUDE_DIR" ]; then
        echo "❌ No .claude directory found"
        echo ""
        return 0
    fi

    # Check if hooks directory exists
    if [ ! -d "$HOOKS_DIR" ]; then
        echo "❌ No hooks directory found"
        echo ""
        return 0
    fi

    echo "📁 Hooks directory: $HOOKS_DIR"
    echo ""

    # Check for specific notification hooks
    WAITING_HOOK="$HOOKS_DIR/waiting-for-input.sh"
    COMPLETED_HOOK="$HOOKS_DIR/task-completed.sh"

    local INSTALLED_COUNT=0

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
                echo "   Hooks configured:"
                jq -r '.hooks | to_entries[] | "   - \(.key): \(.value)"' "$SETTINGS_FILE" 2>/dev/null
            else
                echo "   No hooks configured in settings.json"
            fi
        else
            echo "   (jq not available - cannot parse settings)"
        fi
    else
        echo "⚠️  No settings file found"
    fi

    echo ""

    # Summary for this location
    if [ $INSTALLED_COUNT -eq 0 ]; then
        echo "Status: ❌ No hooks installed at $LEVEL level"
    elif [ $INSTALLED_COUNT -lt 2 ]; then
        echo "Status: ⚠️  Partial installation ($INSTALLED_COUNT of 2 hooks)"
    else
        echo "Status: ✅ All hooks installed at $LEVEL level"
    fi

    echo ""
}

# Check project level
check_hooks_at_location "PROJECT" "./.claude"

# Check user level
check_hooks_at_location "USER" "$HOME/.claude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 TIP: Run '/notifications.install' to install or update hooks"
echo "💡 TIP: Run '/notifications.remove' to uninstall hooks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

#!/bin/bash

# Check notification hooks status at both project and user level

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔔 Claude Code Notification Hooks Status"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to check hooks in a specific settings file
check_settings_file() {
    local SETTINGS_FILE="$1"
    local LABEL="$2"

    echo "───────────────────────────────────────────────────────────────────"
    echo "📄 $LABEL"
    echo "   File: $SETTINGS_FILE"
    echo "───────────────────────────────────────────────────────────────────"

    if [ ! -f "$SETTINGS_FILE" ]; then
        echo "   ❌ File not found"
        echo ""
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        echo "   ⚠️  jq not available - cannot parse settings"
        echo ""
        return 1
    fi

    # Check for notification hooks
    local NOTIFICATION_HOOK=$(jq -r '.hooks.Notification // empty' "$SETTINGS_FILE" 2>/dev/null)
    local STOP_HOOK=$(jq -r '.hooks.Stop // empty' "$SETTINGS_FILE" 2>/dev/null)

    if [ -z "$NOTIFICATION_HOOK" ] && [ -z "$STOP_HOOK" ]; then
        echo "   ❌ No notification hooks configured"
        echo ""
        return 1
    fi

    # Show configured hooks
    if [ -n "$NOTIFICATION_HOOK" ]; then
        echo "   ✅ Notification hook configured"
        echo "      Event: Notification (waiting for input)"
        echo "      Command: $NOTIFICATION_HOOK"
    else
        echo "   ❌ Notification hook not configured"
    fi

    echo ""

    if [ -n "$STOP_HOOK" ]; then
        echo "   ✅ Stop hook configured"
        echo "      Event: Stop (task completed)"
        echo "      Command: $STOP_HOOK"
    else
        echo "   ❌ Stop hook not configured"
    fi

    echo ""

    if [ -n "$NOTIFICATION_HOOK" ] && [ -n "$STOP_HOOK" ]; then
        echo "   Status: ✅ All notification hooks configured"
    else
        echo "   Status: ⚠️  Partial configuration"
    fi

    echo ""
    return 0
}

# Check project level settings
echo "═══════════════════════════════════════════════════════════════════"
echo "📂 PROJECT Level (./.claude/)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

PROJECT_HAS_HOOKS=false

# Check settings.json
if check_settings_file "./.claude/settings.json" "settings.json (committed to git)"; then
    PROJECT_HAS_HOOKS=true
fi

# Check settings.local.json
if check_settings_file "./.claude/settings.local.json" "settings.local.json (local only)"; then
    PROJECT_HAS_HOOKS=true
fi

if [ "$PROJECT_HAS_HOOKS" = false ]; then
    echo "   Overall: ❌ No notification hooks at project level"
    echo ""
fi

# Check user level settings
echo "═══════════════════════════════════════════════════════════════════"
echo "📂 USER Level (~/.claude/)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

check_settings_file "$HOME/.claude/settings.json" "settings.json (user-level)" || {
    echo "   Overall: ❌ No notification hooks at user level"
    echo ""
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 TIP: Run '/notifications.install' to install hooks"
echo "💡 TIP: Run '/notifications.remove' to remove hooks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

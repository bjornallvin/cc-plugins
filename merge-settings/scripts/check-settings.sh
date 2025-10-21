#!/bin/bash

# Check all Claude settings files and show their contents
# Shows user, project, and local project settings with active file highlighted

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Claude Code Settings Files Check"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

USER_SETTINGS="$HOME/.claude/settings.json"
PROJECT_SETTINGS="./.claude/settings.json"
LOCAL_SETTINGS="./.claude/settings.local.json"

# Function to display settings file contents
display_settings_file() {
    local file="$1"
    local label="$2"

    if [ ! -f "$file" ]; then
        echo "[$label] File not found: $file"
        echo ""
        return 1
    fi

    echo "[$label] $file"

    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "  ⚠️  jq not installed - showing raw file"
        cat "$file" | sed 's/^/  /'
        echo ""
        return
    fi

    # Count permissions
    local allow_count=$(jq '.permissions.allow // [] | length' "$file" 2>/dev/null || echo "0")
    local deny_count=$(jq '.permissions.deny // [] | length' "$file" 2>/dev/null || echo "0")

    # Count hooks
    local hooks_count=$(jq '.hooks // {} | length' "$file" 2>/dev/null || echo "0")

    # Get all top-level keys
    local keys=$(jq -r 'keys | join(", ")' "$file" 2>/dev/null || echo "unknown")

    echo "  Summary:"
    echo "    - permissions: $allow_count allow, $deny_count deny"
    echo "    - hooks: $hooks_count configured"
    echo "    - keys: $keys"
    echo ""

    # Show permissions details
    if [ "$allow_count" -gt 0 ] || [ "$deny_count" -gt 0 ]; then
        echo "  Permissions:"
        if [ "$allow_count" -gt 0 ]; then
            echo "    ✓ Allow ($allow_count):"
            jq -r '.permissions.allow[]? // empty' "$file" 2>/dev/null | sed 's/^/      - /'
        fi
        if [ "$deny_count" -gt 0 ]; then
            echo "    ✗ Deny ($deny_count):"
            jq -r '.permissions.deny[]? // empty' "$file" 2>/dev/null | sed 's/^/      - /'
        fi
        echo ""
    fi

    # Show hooks details
    if [ "$hooks_count" -gt 0 ]; then
        echo "  Hooks ($hooks_count):"
        jq -r '.hooks // {} | to_entries[] | "    - \(.key): \(.value)"' "$file" 2>/dev/null
        echo ""
    fi

    # Show other keys
    local other_keys=$(jq -r '[keys[] | select(. != "permissions" and . != "hooks")] | join(", ")' "$file" 2>/dev/null)
    if [ -n "$other_keys" ] && [ "$other_keys" != "" ]; then
        echo "  Other settings: $other_keys"
        echo ""
    fi
}

# Check all settings files
display_settings_file "$USER_SETTINGS" "USER"
display_settings_file "$PROJECT_SETTINGS" "PROJECT"
display_settings_file "$LOCAL_SETTINGS" "LOCAL"

# Determine which settings are active
echo "=== ACTIVE SETTINGS ==="
if [ -f "$LOCAL_SETTINGS" ]; then
    echo "⚡ Local project settings are ACTIVE (highest precedence)"
    echo "   File: $LOCAL_SETTINGS"
    ACTIVE_FILE="$LOCAL_SETTINGS"
elif [ -f "$PROJECT_SETTINGS" ]; then
    echo "⚡ Project settings are ACTIVE (overrides user settings)"
    echo "   File: $PROJECT_SETTINGS"
    ACTIVE_FILE="$PROJECT_SETTINGS"
else
    echo "⚡ User settings are ACTIVE"
    echo "   File: $USER_SETTINGS"
    ACTIVE_FILE="$USER_SETTINGS"
fi
echo ""

# Show what's being overridden
echo "=== OVERRIDDEN SETTINGS ==="
OVERRIDDEN=()
if [ "$ACTIVE_FILE" = "$LOCAL_SETTINGS" ]; then
    [ -f "$PROJECT_SETTINGS" ] && OVERRIDDEN+=("PROJECT: $PROJECT_SETTINGS")
    [ -f "$USER_SETTINGS" ] && OVERRIDDEN+=("USER: $USER_SETTINGS")
elif [ "$ACTIVE_FILE" = "$PROJECT_SETTINGS" ]; then
    [ -f "$USER_SETTINGS" ] && OVERRIDDEN+=("USER: $USER_SETTINGS")
fi

if [ ${#OVERRIDDEN[@]} -gt 0 ]; then
    echo "⚠️  The following settings files are being overridden:"
    for override in "${OVERRIDDEN[@]}"; do
        echo "   - $override"
    done
    echo ""
    echo "💡 TIP: Run 'merge-settings.merge' to merge overridden settings into the active file."
else
    echo "✅ No settings files are being overridden."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

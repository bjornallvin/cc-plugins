#!/bin/bash

# Check .env file permissions across all Claude settings files
# This script checks user, project, and local project settings

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔒 SESSIONSTART HOOK: .env Permissions Check"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

USER_SETTINGS="$HOME/.claude/settings.json"
PROJECT_SETTINGS="./.claude/settings.json"
LOCAL_SETTINGS="./.claude/settings.local.json"

# Function to check for .env patterns in a settings file
check_settings_file() {
    local file="$1"
    local label="$2"

    if [ ! -f "$file" ]; then
        echo "[$label] File not found: $file"
        return 1
    fi

    echo "[$label] $file"

    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "  ⚠️  jq not installed - showing raw permissions section"
        grep -A 20 '"permissions"' "$file" 2>/dev/null || echo "  No permissions found"
        return
    fi

    # Extract allow and deny arrays
    local allow_env=$(jq -r '.permissions.allow[]? // empty | select(contains(".env"))' "$file" 2>/dev/null)
    local deny_env=$(jq -r '.permissions.deny[]? // empty | select(contains(".env"))' "$file" 2>/dev/null)

    if [ -z "$allow_env" ] && [ -z "$deny_env" ]; then
        echo "  No .env-related permissions found"
    else
        if [ -n "$allow_env" ]; then
            echo "  ✓ ALLOW:"
            echo "$allow_env" | sed 's/^/    - /'
        fi
        if [ -n "$deny_env" ]; then
            echo "  ✗ DENY:"
            echo "$deny_env" | sed 's/^/    - /'
        fi
    fi
    echo ""
}

# Check all settings files
check_settings_file "$USER_SETTINGS" "USER"
check_settings_file "$PROJECT_SETTINGS" "PROJECT"
check_settings_file "$LOCAL_SETTINGS" "LOCAL"

# Determine which settings are active
echo "=== ACTIVE SETTINGS ==="
if [ -f "$LOCAL_SETTINGS" ]; then
    echo "⚡ Local project settings are ACTIVE (highest precedence)"
    echo "   File: $LOCAL_SETTINGS"
elif [ -f "$PROJECT_SETTINGS" ]; then
    echo "⚡ Project settings are ACTIVE (overrides user settings)"
    echo "   File: $PROJECT_SETTINGS"
else
    echo "⚡ User settings are ACTIVE"
    echo "   File: $USER_SETTINGS"
fi
echo ""

# Warning about overrides
if [ -f "$PROJECT_SETTINGS" ] || [ -f "$LOCAL_SETTINGS" ]; then
    echo "⚠️  WARNING: Project-level settings completely override user settings!"
    echo "   If project settings have empty/missing deny arrays, user-level"
    echo "   .env protections may NOT be enforced."
fi

echo ""
echo "💡 TIP: Run '/secure-env.check' for detailed analysis by Claude."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

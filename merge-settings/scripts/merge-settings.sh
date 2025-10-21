#!/bin/bash

# Merge settings from overridden files into the active settings file
# This preserves settings that would otherwise be lost due to file precedence

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Claude Code Settings Merge"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

USER_SETTINGS="$HOME/.claude/settings.json"
PROJECT_SETTINGS="./.claude/settings.json"
LOCAL_SETTINGS="./.claude/settings.local.json"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ ERROR: jq is not installed"
    echo "   Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

# Determine which settings are active
ACTIVE_FILE=""
OVERRIDDEN_FILES=()

if [ -f "$LOCAL_SETTINGS" ]; then
    ACTIVE_FILE="$LOCAL_SETTINGS"
    [ -f "$PROJECT_SETTINGS" ] && OVERRIDDEN_FILES+=("$PROJECT_SETTINGS")
    [ -f "$USER_SETTINGS" ] && OVERRIDDEN_FILES+=("$USER_SETTINGS")
elif [ -f "$PROJECT_SETTINGS" ]; then
    ACTIVE_FILE="$PROJECT_SETTINGS"
    [ -f "$USER_SETTINGS" ] && OVERRIDDEN_FILES+=("$USER_SETTINGS")
else
    ACTIVE_FILE="$USER_SETTINGS"
fi

# Check if there's anything to merge
if [ ${#OVERRIDDEN_FILES[@]} -eq 0 ]; then
    echo "ℹ️  No overridden settings files found."
    echo ""
    if [ "$ACTIVE_FILE" = "$USER_SETTINGS" ]; then
        echo "Current active file: $USER_SETTINGS"
        echo ""
        echo "💡 TIP: Create ./.claude/settings.json for project-specific settings."
    else
        echo "Current active file: $ACTIVE_FILE"
        echo "All settings are contained in the active file."
    fi
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

echo "Found overridden files:"
for file in "${OVERRIDDEN_FILES[@]}"; do
    allow_count=$(jq '.permissions.allow // [] | length' "$file" 2>/dev/null || echo "0")
    deny_count=$(jq '.permissions.deny // [] | length' "$file" 2>/dev/null || echo "0")
    hooks_count=$(jq '.hooks // {} | length' "$file" 2>/dev/null || echo "0")
    echo "  - $file"
    echo "    ($allow_count allow, $deny_count deny, $hooks_count hooks)"
done
echo ""
echo "Active file: $ACTIVE_FILE"
echo ""

# Create a temporary merged file
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

# Start with active file as base
if [ -f "$ACTIVE_FILE" ]; then
    cp "$ACTIVE_FILE" "$TEMP_FILE"
else
    echo '{}' > "$TEMP_FILE"
fi

# Track changes for reporting
ADDED_ALLOW=0
ADDED_DENY=0
ADDED_HOOKS=0
CONFLICTS=()

# Merge each overridden file into the temp file
for override_file in "${OVERRIDDEN_FILES[@]}"; do
    # Merge permissions.allow
    jq --slurpfile override "$override_file" '
        .permissions.allow = (
            (.permissions.allow // []) + ($override[0].permissions.allow // []) | unique
        )
    ' "$TEMP_FILE" > "$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"

    # Merge permissions.deny
    jq --slurpfile override "$override_file" '
        .permissions.deny = (
            (.permissions.deny // []) + ($override[0].permissions.deny // []) | unique
        )
    ' "$TEMP_FILE" > "$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"

    # Merge hooks (with conflict detection)
    if [ "$(jq '.hooks // {} | length' "$override_file")" -gt 0 ]; then
        # Get hook keys from override file
        hook_keys=$(jq -r '.hooks // {} | keys[]' "$override_file")
        for hook_key in $hook_keys; do
            override_value=$(jq -r --arg key "$hook_key" '.hooks[$key] // empty' "$override_file")
            active_value=$(jq -r --arg key "$hook_key" '.hooks[$key] // empty' "$TEMP_FILE")

            if [ -z "$active_value" ]; then
                # Hook doesn't exist in active, add it
                jq --arg key "$hook_key" --arg value "$override_value" '
                    .hooks[$key] = $value
                ' "$TEMP_FILE" > "$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
                ((ADDED_HOOKS++))
            elif [ "$active_value" != "$override_value" ]; then
                # Hook exists with different value - conflict
                CONFLICTS+=("hook '$hook_key': active='$active_value', overridden='$override_value'")
            fi
        done
    fi

    # Merge other top-level keys (not permissions or hooks)
    other_keys=$(jq -r '[keys[] | select(. != "permissions" and . != "hooks")] | .[]' "$override_file" 2>/dev/null || echo "")
    for key in $other_keys; do
        override_value=$(jq --arg key "$key" '.[$key]' "$override_file")
        active_value=$(jq --arg key "$key" '.[$key] // empty' "$TEMP_FILE")

        if [ "$active_value" = "null" ] || [ -z "$active_value" ]; then
            # Key doesn't exist in active, add it
            jq --arg key "$key" --argjson value "$override_value" '
                .[$key] = $value
            ' "$TEMP_FILE" > "$TEMP_FILE.tmp" && mv "$TEMP_FILE.tmp" "$TEMP_FILE"
        elif [ "$active_value" != "$override_value" ]; then
            # Key exists with different value - conflict
            CONFLICTS+=("key '$key': values differ (keeping active file's value)")
        fi
    done
done

# Calculate what changed
if [ -f "$ACTIVE_FILE" ]; then
    OLD_ALLOW=$(jq '.permissions.allow // [] | length' "$ACTIVE_FILE")
    OLD_DENY=$(jq '.permissions.deny // [] | length' "$ACTIVE_FILE")
else
    OLD_ALLOW=0
    OLD_DENY=0
fi

NEW_ALLOW=$(jq '.permissions.allow // [] | length' "$TEMP_FILE")
NEW_DENY=$(jq '.permissions.deny // [] | length' "$TEMP_FILE")

ADDED_ALLOW=$((NEW_ALLOW - OLD_ALLOW))
ADDED_DENY=$((NEW_DENY - OLD_DENY))

# Show merge preview
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Merge Preview:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ADDED_ALLOW -gt 0 ]; then
    echo "  ✓ Adding $ADDED_ALLOW new allow patterns"
fi
if [ $ADDED_DENY -gt 0 ]; then
    echo "  ✓ Adding $ADDED_DENY new deny patterns"
fi
if [ $ADDED_HOOKS -gt 0 ]; then
    echo "  ✓ Adding $ADDED_HOOKS new hooks"
fi

if [ ${#CONFLICTS[@]} -gt 0 ]; then
    echo ""
    echo "  ⚠️  Conflicts detected (keeping active file's values):"
    for conflict in "${CONFLICTS[@]}"; do
        echo "    - $conflict"
    done
fi

if [ $ADDED_ALLOW -eq 0 ] && [ $ADDED_DENY -eq 0 ] && [ $ADDED_HOOKS -eq 0 ]; then
    echo "  ℹ️  No new settings to merge (all settings already present in active file)"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

echo ""

# Create backup
BACKUP_FILE="$ACTIVE_FILE.backup-$(date '+%Y%m%d-%H%M%S')"
if [ -f "$ACTIVE_FILE" ]; then
    cp "$ACTIVE_FILE" "$BACKUP_FILE"
    echo "📝 Created backup: $BACKUP_FILE"
    echo ""
fi

# Ask for confirmation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Ready to merge settings into: $ACTIVE_FILE"
echo ""
read -p "Apply merge? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "❌ Merge cancelled."
    [ -f "$BACKUP_FILE" ] && rm "$BACKUP_FILE" && echo "   Removed backup file."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

echo ""

# Create .claude directory if needed
mkdir -p "$(dirname "$ACTIVE_FILE")"

# Apply the merge
cp "$TEMP_FILE" "$ACTIVE_FILE"

echo "✅ Merged successfully!"
echo ""
echo "Summary:"
[ $ADDED_ALLOW -gt 0 ] && echo "  - Added $ADDED_ALLOW allow patterns"
[ $ADDED_DENY -gt 0 ] && echo "  - Added $ADDED_DENY deny patterns"
[ $ADDED_HOOKS -gt 0 ] && echo "  - Added $ADDED_HOOKS hooks"
[ ${#CONFLICTS[@]} -gt 0 ] && echo "  - Resolved ${#CONFLICTS[@]} conflicts (kept active file's values)"
echo ""
echo "💡 Run 'merge-settings.check' to verify the merged settings."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

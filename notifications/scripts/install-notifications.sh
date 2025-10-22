#!/bin/bash

# Install notification hooks at project or user level
# Usage:
#   install-notifications.sh user
#   install-notifications.sh project [settings|local]

INSTALL_LEVEL="$1"
SETTINGS_TYPE="$2"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔔 Installing Claude Code Notification Hooks"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Plugin location
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/marketplaces/cc-plugins/notifications}"
PLUGIN_HOOKS="$PLUGIN_ROOT/hooks"

# Validate and set target based on argument
case "$INSTALL_LEVEL" in
    project)
        TARGET_CLAUDE="./.claude"

        # Determine which settings file to use
        case "$SETTINGS_TYPE" in
            settings)
                SETTINGS_FILE="$TARGET_CLAUDE/settings.json"
                echo "Installing at project level: $TARGET_CLAUDE"
                echo "Using: settings.json (committed to git)"
                ;;
            local)
                SETTINGS_FILE="$TARGET_CLAUDE/settings.local.json"
                echo "Installing at project level: $TARGET_CLAUDE"
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
        echo "Installing at user level: $TARGET_CLAUDE"
        ;;
    *)
        echo "❌ Invalid installation level: '$INSTALL_LEVEL'"
        echo ""
        echo "Usage:"
        echo "  $0 user"
        echo "  $0 project [settings|local]"
        echo ""
        echo "Levels:"
        echo "  project - Install hooks at project level (./.claude/)"
        echo "  user    - Install hooks at user level (~/.claude/)"
        exit 1
        ;;
esac

echo ""

# Create .claude directory if it doesn't exist
if [ ! -d "$TARGET_CLAUDE" ]; then
    echo "📁 Creating .claude directory..."
    mkdir -p "$TARGET_CLAUDE"
    echo "   ✓ Created: $TARGET_CLAUDE"
    echo ""
fi

# Verify plugin hooks exist
WAITING_HOOK="$PLUGIN_HOOKS/waiting-for-input.sh"
COMPLETED_HOOK="$PLUGIN_HOOKS/task-completed.sh"

if [ ! -f "$WAITING_HOOK" ] || [ ! -f "$COMPLETED_HOOK" ]; then
    echo "❌ Plugin hooks not found in: $PLUGIN_HOOKS"
    echo ""
    echo "Expected files:"
    echo "  - $WAITING_HOOK"
    echo "  - $COMPLETED_HOOK"
    echo ""
    echo "Please ensure the plugin is properly installed."
    exit 1
fi

echo "✓ Plugin hooks verified in: $PLUGIN_HOOKS"
echo ""

# Update settings file to configure hooks
echo "⚙️  Configuring hooks in settings file..."

# Create backup if settings file exists
if [ -f "$SETTINGS_FILE" ]; then
    BACKUP_FILE="${SETTINGS_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "   ✓ Backup created: $BACKUP_FILE"
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "   ⚠️  jq not installed - cannot auto-configure settings file"
    echo "   Please manually add these hooks to $SETTINGS_FILE:"
    echo ""
    echo '   "hooks": {'
    echo "     \"Notification\": \"bash $WAITING_HOOK\","
    echo "     \"Stop\": \"bash $COMPLETED_HOOK\""
    echo '   }'
    echo ""
else
    # Use jq to update settings - only modify hooks property
    TEMP_FILE=$(mktemp)

    if [ ! -f "$SETTINGS_FILE" ] && [ ! -L "$SETTINGS_FILE" ]; then
        # Create new settings file with just hooks
        echo '{}' | jq --arg waiting "$WAITING_HOOK" --arg completed "$COMPLETED_HOOK" '.hooks = {
          "Notification": [
            {
              "matcher": "",
              "hooks": [
                {
                  "type": "command",
                  "command": ("bash " + $waiting)
                }
              ]
            }
          ],
          "Stop": [
            {
              "matcher": "",
              "hooks": [
                {
                  "type": "command",
                  "command": ("bash " + $completed)
                }
              ]
            }
          ]
        }' > "$SETTINGS_FILE"
        echo "   ✓ Created $SETTINGS_FILE with hooks"
    else
        # Check if it's a symlink
        if [ -L "$SETTINGS_FILE" ]; then
            echo "   ℹ️  Detected symlink, preserving it"
        fi

        # Update existing settings file - merge hooks property
        # Using cat instead of mv to preserve symlinks
        jq --arg waiting "$WAITING_HOOK" --arg completed "$COMPLETED_HOOK" '
          .hooks.Notification = [
            {
              "matcher": "",
              "hooks": [
                {
                  "type": "command",
                  "command": ("bash " + $waiting)
                }
              ]
            }
          ] |
          .hooks.Stop = [
            {
              "matcher": "",
              "hooks": [
                {
                  "type": "command",
                  "command": ("bash " + $completed)
                }
              ]
            }
          ]
        ' "$SETTINGS_FILE" > "$TEMP_FILE"

        cat "$TEMP_FILE" > "$SETTINGS_FILE"
        rm "$TEMP_FILE"
        echo "   ✓ Updated hooks in $SETTINGS_FILE"
        echo "   ℹ️  All other settings preserved"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Notification hooks installed successfully at $INSTALL_LEVEL level!"
echo ""
echo "Hooks configured in: $SETTINGS_FILE"
echo "  • Notification → $WAITING_HOOK"
echo "  • Stop → $COMPLETED_HOOK"
echo ""
echo "💡 TIP: Run '/notifications.check' to verify the installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

#!/bin/bash

# Install notification hooks at project or user level
# Usage: install-notifications.sh [project|user]

INSTALL_LEVEL="$1"

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
        TARGET_HOOKS="$TARGET_CLAUDE/hooks"
        SETTINGS_FILE="$TARGET_CLAUDE/settings.json"
        HOOK_PATH_PREFIX="./.claude/hooks"
        echo "Installing at project level: $TARGET_CLAUDE"
        ;;
    user)
        TARGET_CLAUDE="$HOME/.claude"
        TARGET_HOOKS="$TARGET_CLAUDE/hooks"
        SETTINGS_FILE="$TARGET_CLAUDE/settings.json"
        HOOK_PATH_PREFIX="$HOME/.claude/hooks"
        echo "Installing at user level: $TARGET_CLAUDE"
        ;;
    *)
        echo "❌ Invalid installation level: '$INSTALL_LEVEL'"
        echo ""
        echo "Usage: $0 [project|user]"
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
fi

# Create hooks directory if it doesn't exist
if [ ! -d "$TARGET_HOOKS" ]; then
    echo "📁 Creating hooks directory..."
    mkdir -p "$TARGET_HOOKS"
    echo "   ✓ Created: $TARGET_HOOKS"
fi

echo ""

# Copy hook scripts
echo "📋 Copying hook scripts..."

WAITING_HOOK="waiting-for-input.sh"
COMPLETED_HOOK="task-completed.sh"

if [ -f "$PLUGIN_HOOKS/$WAITING_HOOK" ]; then
    cp "$PLUGIN_HOOKS/$WAITING_HOOK" "$TARGET_HOOKS/"
    chmod +x "$TARGET_HOOKS/$WAITING_HOOK"
    echo "   ✓ Copied: $WAITING_HOOK"
else
    echo "   ⚠️  Source not found: $PLUGIN_HOOKS/$WAITING_HOOK"
fi

if [ -f "$PLUGIN_HOOKS/$COMPLETED_HOOK" ]; then
    cp "$PLUGIN_HOOKS/$COMPLETED_HOOK" "$TARGET_HOOKS/"
    chmod +x "$TARGET_HOOKS/$COMPLETED_HOOK"
    echo "   ✓ Copied: $COMPLETED_HOOK"
else
    echo "   ⚠️  Source not found: $PLUGIN_HOOKS/$COMPLETED_HOOK"
fi

echo ""

# Update settings.json to configure hooks
echo "⚙️  Configuring hooks in settings.json..."

# Create backup if settings file exists
if [ -f "$SETTINGS_FILE" ]; then
    BACKUP_FILE="${SETTINGS_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    echo "   ✓ Backup created: $BACKUP_FILE"
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "   ⚠️  jq not installed - cannot auto-configure settings.json"
    echo "   Please manually add hooks to $SETTINGS_FILE:"
    echo ""
    echo '   {'
    echo '     "hooks": {'
    echo "       \"Notification\": \"bash $HOOK_PATH_PREFIX/waiting-for-input.sh\","
    echo "       \"Stop\": \"bash $HOOK_PATH_PREFIX/task-completed.sh\""
    echo '     }'
    echo '   }'
    echo ""
else
    # Use jq to update settings
    if [ ! -f "$SETTINGS_FILE" ]; then
        # Create new settings file
        echo '{}' | jq --arg prefix "$HOOK_PATH_PREFIX" '.hooks = {
          "Notification": ("bash " + $prefix + "/waiting-for-input.sh"),
          "Stop": ("bash " + $prefix + "/task-completed.sh")
        }' > "$SETTINGS_FILE"
        echo "   ✓ Created settings.json with hooks"
    else
        # Update existing settings file
        TEMP_FILE=$(mktemp)
        jq --arg prefix "$HOOK_PATH_PREFIX" \
            '.hooks.Notification = ("bash " + $prefix + "/waiting-for-input.sh") |
            .hooks.Stop = ("bash " + $prefix + "/task-completed.sh")' \
            "$SETTINGS_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$SETTINGS_FILE"
        echo "   ✓ Updated settings.json with hooks"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Notification hooks installed successfully at $INSTALL_LEVEL level!"
echo ""
echo "Installed hooks:"
echo "  • Waiting for input: $TARGET_HOOKS/$WAITING_HOOK"
echo "  • Task completed: $TARGET_HOOKS/$COMPLETED_HOOK"
echo ""
echo "Settings configured in: $SETTINGS_FILE"
echo ""
echo "💡 TIP: Run '/notifications.check' to verify the installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

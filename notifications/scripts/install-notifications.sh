#!/bin/bash

# Install notification hooks to the current project

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔔 Installing Claude Code Notification Hooks"
echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Plugin location
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/marketplaces/cc-plugins/notifications}"
PLUGIN_HOOKS="$PLUGIN_ROOT/hooks"

# Project locations
PROJECT_CLAUDE="./.claude"
PROJECT_HOOKS="$PROJECT_CLAUDE/hooks"
SETTINGS_FILE="$PROJECT_CLAUDE/settings.json"

# Create .claude directory if it doesn't exist
if [ ! -d "$PROJECT_CLAUDE" ]; then
    echo "📁 Creating .claude directory..."
    mkdir -p "$PROJECT_CLAUDE"
    echo "   ✓ Created: $PROJECT_CLAUDE"
fi

# Create hooks directory if it doesn't exist
if [ ! -d "$PROJECT_HOOKS" ]; then
    echo "📁 Creating hooks directory..."
    mkdir -p "$PROJECT_HOOKS"
    echo "   ✓ Created: $PROJECT_HOOKS"
fi

echo ""

# Copy hook scripts
echo "📋 Copying hook scripts..."

WAITING_HOOK="waiting-for-input.sh"
COMPLETED_HOOK="task-completed.sh"

if [ -f "$PLUGIN_HOOKS/$WAITING_HOOK" ]; then
    cp "$PLUGIN_HOOKS/$WAITING_HOOK" "$PROJECT_HOOKS/"
    chmod +x "$PROJECT_HOOKS/$WAITING_HOOK"
    echo "   ✓ Copied: $WAITING_HOOK"
else
    echo "   ⚠️  Source not found: $PLUGIN_HOOKS/$WAITING_HOOK"
fi

if [ -f "$PLUGIN_HOOKS/$COMPLETED_HOOK" ]; then
    cp "$PLUGIN_HOOKS/$COMPLETED_HOOK" "$PROJECT_HOOKS/"
    chmod +x "$PROJECT_HOOKS/$COMPLETED_HOOK"
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
    echo '       "Notification": "bash ./.claude/hooks/waiting-for-input.sh",'
    echo '       "Stop": "bash ./.claude/hooks/task-completed.sh"'
    echo '     }'
    echo '   }'
    echo ""
else
    # Use jq to update settings
    if [ ! -f "$SETTINGS_FILE" ]; then
        # Create new settings file
        echo '{}' | jq '.hooks = {
          "Notification": "bash ./.claude/hooks/waiting-for-input.sh",
          "Stop": "bash ./.claude/hooks/task-completed.sh"
        }' > "$SETTINGS_FILE"
        echo "   ✓ Created settings.json with hooks"
    else
        # Update existing settings file
        TEMP_FILE=$(mktemp)
        jq '.hooks.Notification = "bash ./.claude/hooks/waiting-for-input.sh" |
            .hooks.Stop = "bash ./.claude/hooks/task-completed.sh"' \
            "$SETTINGS_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$SETTINGS_FILE"
        echo "   ✓ Updated settings.json with hooks"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Notification hooks installed successfully!"
echo ""
echo "Installed hooks:"
echo "  • Waiting for input: $PROJECT_HOOKS/$WAITING_HOOK"
echo "  • Task completed: $PROJECT_HOOKS/$COMPLETED_HOOK"
echo ""
echo "💡 TIP: Run '/notifications.check' to verify the installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

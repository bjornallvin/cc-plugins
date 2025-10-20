#!/bin/bash

# Apply secure .env deny rules to project-level settings
# This merges .env protections without overwriting existing settings

set -e

PROJECT_SETTINGS="./.claude/settings.json"
LOCAL_SETTINGS="./.claude/settings.local.json"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔒 Applying Secure .env Deny Rules to Project Settings"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ ERROR: jq is not installed"
    echo "   Install with: brew install jq"
    exit 1
fi

# Create .claude directory if it doesn't exist
mkdir -p ./.claude

# Define the .env deny rules to add/ensure
ENV_DENY_RULES='[
  "Read(**/.env)",
  "Write(**/.env)",
  "Read(**/.env.local)",
  "Write(**/.env.local)"
]'

ENV_ALLOW_RULES='[
  "Read(**/.env.example)",
  "Write(**/.env.example)"
]'

# Function to apply rules to a settings file
apply_rules_to_file() {
    local file="$1"
    local label="$2"

    if [ -f "$file" ]; then
        echo "📝 Updating existing $label: $file"

        # Backup existing file
        cp "$file" "$file.backup"
        echo "   Created backup: $file.backup"

        # Merge .env deny rules into existing deny array (removing duplicates)
        # Also merge .env.example allow rules
        jq --argjson envDeny "$ENV_DENY_RULES" --argjson envAllow "$ENV_ALLOW_RULES" '
          .permissions.deny = (
            (.permissions.deny // []) + $envDeny | unique
          ) |
          .permissions.allow = (
            (.permissions.allow // []) + $envAllow | unique
          )
        ' "$file" > "$file.tmp"

        mv "$file.tmp" "$file"
    else
        echo "📝 Creating new $label: $file"

        # Create new settings file with secure permissions
        jq -n --argjson envDeny "$ENV_DENY_RULES" --argjson envAllow "$ENV_ALLOW_RULES" '{
          permissions: {
            allow: $envAllow,
            deny: $envDeny
          }
        }' > "$file"
    fi
}

# Apply to settings.json
apply_rules_to_file "$PROJECT_SETTINGS" "project settings"
echo ""

# Apply to settings.local.json if it exists or will be created
if [ -f "$LOCAL_SETTINGS" ]; then
    echo "⚠️  Found settings.local.json (takes precedence over settings.json)"
    apply_rules_to_file "$LOCAL_SETTINGS" "local project settings"
    echo ""
    echo "✅ Applied rules to BOTH settings.json and settings.local.json"
    echo "   (settings.local.json is the active configuration)"
else
    echo "✅ Applied rules to settings.json"
    echo "   (No settings.local.json found - settings.json is active)"
fi

echo ""
echo "Added/ensured deny rules:"
echo "  ✗ Read(**/.env)"
echo "  ✗ Write(**/.env)"
echo "  ✗ Read(**/.env.local)"
echo "  ✗ Write(**/.env.local)"
echo ""
echo "Added/ensured allow rules:"
echo "  ✓ Read(**/.env.example)"
echo "  ✓ Write(**/.env.example)"
echo ""
echo "⚠️  IMPORTANT: Project-level settings override user-level settings!"
echo "   Run '/secure-env.check' to verify the effective configuration."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

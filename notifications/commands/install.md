Install notification hooks at either project or user level.

This adds hooks for:
- Audio/popup notification when Claude is waiting for input (Notification event)
- Audio/popup notification when Claude completes a task (Stop event)

**Before running the script, ask the user:**

1. **Installation level**: "Where would you like to install notification hooks?"
   - Option 1: "Project level (./.claude/) - Only for this project"
   - Option 2: "User level (~/.claude/) - All projects"

2. **If project level was chosen**, ask: "Which settings file should we use?"
   - Option 1: "settings.json - Committed to git, shared with team"
   - Option 2: "settings.local.json - Local only, not committed (in .gitignore)"

3. Based on their answers, run the installation script:

```bash
# If user chooses USER level:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/install-notifications.sh user

# If user chooses PROJECT level with settings.json:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/install-notifications.sh project settings

# If user chooses PROJECT level with settings.local.json:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/install-notifications.sh project local
```

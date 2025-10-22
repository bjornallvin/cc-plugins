Remove notification hooks from either project or user level.

**Before running the script, ask the user:**

1. **Removal level**: "Where would you like to remove notification hooks from?"
   - Option 1: "Project level (./.claude/) - Only this project"
   - Option 2: "User level (~/.claude/) - All projects"

2. **If project level was chosen**, ask: "Which settings file should we update?"
   - Option 1: "settings.json - Committed to git, shared with team"
   - Option 2: "settings.local.json - Local only, not committed (in .gitignore)"

3. Based on their answers, run the removal script:

```bash
# If user chooses USER level:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/remove-notifications.sh user

# If user chooses PROJECT level with settings.json:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/remove-notifications.sh project settings

# If user chooses PROJECT level with settings.local.json:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/remove-notifications.sh project local
```

Remove notification hooks from either project or user level.

**Before running the script:**

1. Ask the user: "Where would you like to remove notification hooks from?"
   - Option 1: "Project level (./.claude/) - Only this project"
   - Option 2: "User level (~/.claude/) - All projects"

2. Based on their answer, run the removal script with the appropriate argument:

```bash
# If user chooses project level:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/remove-notifications.sh project

# If user chooses user level:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/remove-notifications.sh user
```

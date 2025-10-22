Install notification hooks at either project or user level.

This adds hooks for:
- Audio/popup notification when Claude is waiting for input (Notification event)
- Audio/popup notification when Claude completes a task (Stop event)

**Before running the script:**

1. Ask the user: "Where would you like to install notification hooks?"
   - Option 1: "Project level (./.claude/) - Only for this project"
   - Option 2: "User level (~/.claude/) - All projects"

2. Based on their answer, run the installation script with the appropriate argument:

```bash
# If user chooses project level:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/install-notifications.sh project

# If user chooses user level:
bash ~/.claude/plugins/marketplaces/cc-plugins/notifications/scripts/install-notifications.sh user
```

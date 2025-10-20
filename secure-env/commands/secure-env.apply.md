Apply secure .env permission deny rules to the current project's Claude settings.

This command runs a script that:
- Adds deny rules for `.env` and `.env.local` files
- Adds allow rules for `.env.example` files
- Applies to **BOTH** `.claude/settings.json` AND `.claude/settings.local.json` (if they exist)
- Preserves all existing project settings (only merges the .env rules)
- Creates backups before modifying
- Creates the settings files if they don't exist

**Important**:
- `.claude/settings.local.json` takes precedence over `.claude/settings.json`
- That's why the script applies rules to BOTH files to ensure protection
- Project-level settings override user-level settings

After running this command, use `/local.check-env-permissions` to verify the configuration.

```bash
~/.claude/scripts/apply-env-security.sh
```

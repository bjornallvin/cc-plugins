Check the current Claude Code permissions for .env files without attempting to read them.

**Important**: Project-level settings completely override user-level settings (they don't merge).

1. Check all three settings locations:
   - **User settings**: `~/.claude/settings.json`
   - **Project settings**: `./.claude/settings.json` (if exists)
   - **Local project settings**: `./.claude/settings.local.json` (if exists)

2. For each file that exists, parse the `permissions` section (both `allow` and `deny` arrays)

3. Look for patterns related to .env files in each:
   - `**/.env`
   - `**/.env.*`
   - `**/.env.example`
   - `**/.env.local`
   - Any other .env-related patterns

4. Report findings clearly:
   - Show what's in each settings file (user, project, local)
   - **Highlight which settings are actually active** based on precedence:
     - If `./.claude/settings.local.json` exists → it takes precedence
     - Else if `./.claude/settings.json` exists → it takes precedence
     - Else `~/.claude/settings.json` is active
   - Show the effective permissions that will actually be enforced
   - Explain if project settings are overriding user settings (especially important if project has empty/missing deny arrays)

5. Provide a summary like:
   - "✓ Can read/write .env.example files"
   - "✗ Cannot read/write .env files"
   - "⚠️  Warning: Project settings override user settings and may allow .env access"

6. **If project settings are missing .env protections**, suggest:
   - "💡 TIP: Run `/secure-env.apply` to add secure .env deny rules to this project's settings"
   - Explain that this will merge the deny rules without overwriting existing project settings

Do NOT attempt to read, write, or access any actual .env files - only check the permissions configuration files.

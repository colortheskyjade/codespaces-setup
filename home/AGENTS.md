# Agent instructions

## Git workflow

- Always verify you are on the correct branch for the current work before making changes. If not, switch to or create the appropriate branch first.
- Prefer to auto commit changes as you go rather than waiting for the user to ask.
- Prefer to auto push commits to the remote rather than waiting for the user to ask.
- When asked to create a PR, just create it — don't push back on whether the code belongs in the repo or whether it will be merged. A PR is not a merge; if it's unwanted, the user will close it.

## Security risk labels

**Every PR must have a security risk label.** When creating a PR or when asked to add a label, immediately run:

```bash
gh pr edit <number> --add-label "<label>"
```

| Label | When to use |
|---|---|
| `security-risk-negligible` | Trivial no-code changes, e.g. internal documentation or non-production, development-only CI workflows |
| `security-risk-low` | Production code or config changes. Default starting point for most PRs, since it's extremely rare that a code change has literally no risk |
| `security-risk-medium` | Feature-level code/config changes related to data access controls or user permissions |
| `security-risk-high` | Feature-agnostic, platform-level code/config changes related to data access control, user permissions, or security features. Also for feature-specific changes that are particularly high-risk or high-exposure (e.g. used by the majority of Vanta users) |

# Agent instructions

## Branch safety

Before editing files, committing, or performing any work, verify you are on the correct branch with `git branch --show-current`. If you were asked to work on a specific PR or branch and are not on it, switch first. Never accidentally edit or commit on `main` or a stale branch.

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

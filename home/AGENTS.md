# Agent instructions

These notes apply when helping with pull requests and repository work.

## Security risk labels on pull requests

When you create or prepare a pull request, you **must** apply a security risk label. Do not skip this step, even for small or "obvious" changes.

### Labels

Use exactly one of these labels:

| Label | When to use |
|---|---|
| `security-risk-negligible` | Trivial no-code changes, e.g. internal documentation or non-production, development-only CI workflows |
| `security-risk-low` | Production code or config changes. Default starting point for most PRs, since it's extremely rare that a code change has literally no risk |
| `security-risk-medium` | Feature-level code/config changes related to data access controls or user permissions |
| `security-risk-high` | Feature-agnostic, platform-level code/config changes related to data access control, user permissions, or security features. Also for feature-specific changes that are particularly high-risk or high-exposure (e.g. used by the majority of Vanta users) |

### How to apply

After creating the PR, apply the label with:

```bash
gh pr edit <number> --add-label "<label>"
```

### When in doubt

When impact is unclear, **prefer a more conservative (higher) risk** classification.

# Agent instructions

These notes apply when helping with pull requests and repository work.

## Security risk labels on pull requests

When you create or prepare a pull request, you **must** apply a security risk label. Do not skip this step, even for small or "obvious" changes.

### Labels

Use exactly one of these labels:

| Label | When to use |
|---|---|
| `security-risk-negligible` | UI tweaks, refactoring, docs, CI config, test-only changes |
| `security-risk-low` | Internal logic, new dependencies, minor auth-adjacent code |
| `security-risk-medium` | Auth, validation, external API integrations, data model changes |
| `security-risk-high` | Core security, encryption, secrets handling, sensitive data flows |

### How to apply

After creating the PR, apply the label with:

```bash
gh pr edit <number> --add-label "<label>"
```

### When in doubt

When impact is unclear, **prefer a more conservative (higher) risk** classification.

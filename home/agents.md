# Agent instructions

These notes apply when helping with pull requests and repository work.

## Security risk labels on pull requests

When you create or prepare a pull request (including drafting the title, body, or checklist for the user), you **must** include a **security risk** label recommendation.

### Mandatory behavior

1. **Always** propose which security-risk label the PR should use. Do not skip this step, even for small or “obvious” changes.
2. **Choose the label from the repository’s own rules**, not from a generic guess. Before deciding, look for documented guidance, for example:
   - `CONTRIBUTING.md`, `SECURITY.md`, or similar project docs
   - `.github/` (pull request templates, issue templates, label descriptions, workflows that mention risk levels)
   - Internal runbooks or engineering handbooks linked from the repo
3. If the repo defines explicit label names and criteria (e.g. “Security: Low / Medium / High” or a numbered scale), **map the PR to those names and definitions** using both the **diff** and the **PR description**.
4. If the repo does **not** document a taxonomy, infer the appropriate label from:
   - The **nature of the change** (authentication, authorization, secrets, crypto, dependencies, network boundaries, parsing untrusted input, supply chain, etc.)
   - **Scope of exposure** (who can trigger it, what data or systems are affected)
   - **Defense in depth**: when documentation is missing and impact is unclear, **prefer a more conservative (higher) risk** classification and say why briefly in the PR text.

### What to put in the PR

State the recommended label clearly (exact string the project uses) and add one or two sentences tying it to concrete files or behaviors in the change, so reviewers can agree or correct it quickly.

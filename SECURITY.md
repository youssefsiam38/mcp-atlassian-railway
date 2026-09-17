# Security

## Per-request authentication, no stored Atlassian credential

In this multi-user HTTP deployment, the server holds **no global Atlassian credential**. Every `/mcp` request must
carry the caller's own Atlassian credential in the `Authorization` header; a request without one is rejected
(`401`, "Authentication required: no Atlassian credentials were provided"). This means:

- the endpoint cannot leak one operator's Atlassian access to another — each caller acts as themselves, with their
  own permissions;
- an anonymous request to `/mcp` gets nothing.

Verified in the smoke and live tests: `POST /mcp` without a credential is rejected; the MCP handshake works once a
credential header is present. (Actual Jira/Confluence operations require a real Atlassian token — the caller's — and
are not exercised by the tests, which use a placeholder header only to reach the handshake.)

## What the template does

- **Auth gate on.** The multi-user `UserTokenMiddleware` enforces a per-request credential; no unauthenticated
  access to Atlassian tools.
- **Stateless.** No volume, no database, no stored secret to protect at rest.
- **Pinned image.** The official image is pinned by digest (see `UPSTREAM.md`); the application is unmodified.
- **Secret hygiene.** No secret is committed; the static test greps the tree for credential shapes.

## What you should do

- **Choose the right auth model for your Atlassian** (PAT for Server/DC, OAuth for Cloud) and give each user only
  the tokens/scopes they need — the server acts with whatever token the caller presents.
- **Consider `READ_ONLY_MODE=true`** for a shared or exploratory endpoint, so callers can only read.
- **Restrict who can reach the URL** if you don't want the endpoint public — for example with a custom domain and
  your own proxy — since anyone with a valid Atlassian token could otherwise use your instance's compute.
- **Do not put any Atlassian token in the template's variables** unless you deliberately want a single shared
  identity; the intended model is per-request, per-user tokens.

## Reporting

For issues in mcp-atlassian itself, report upstream. For issues specific to this template's packaging, open an issue
on the template repository.

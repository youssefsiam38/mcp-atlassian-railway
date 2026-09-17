# Railway template configuration

The template's exact configuration. Reproduce it from this file if it ever has to be rebuilt.

| | |
|---|---|
| Name | MCP Atlassian |
| Code | `mcp-atlassian` |
| Template id | `04fc831f-3c26-4e9e-8524-dc77980c3f6b` |
| Deploy URL | https://railway.com/deploy/mcp-atlassian |
| Category | AI/ML |
| Card description | A remote MCP server for Jira & Confluence (streamable-HTTP, multi-user). |
| Icon | `assets/icon.png` |
| Overview markdown | `marketplace/OVERVIEW.md` (Railway enforces its section headings) |

Generated values use Railway's `secret()` function: `hexN` is `${{secret(N, "abcdef0123456789")}}` and `alnumN` is
`${{secret(N, "a-zA-Z0-9")}}` spelled out. Alphanumeric passwords are used wherever a value is embedded in a
connection URL, so nothing needs percent-encoding. Images are referenced by tag, because the template generator
rejects digests; `UPSTREAM.md` records the digests.

## Services

### `mcp`

| Field | Value |
|---|---|
| Source | `ghcr.io/sooperset/mcp-atlassian:0.23.1` |
| Public domain | target port 9000 |
| Volume | none |
| Healthcheck | `/healthz`, timeout from `RAILWAY_HEALTHCHECK_TIMEOUT_SEC` |
| Restart policy | on failure, 10 retries |

| Variable | Value |
|---|---|
| `TRANSPORT` | `streamable-http` |
| `PORT` | `9000` |
| `STATELESS` | `true` |
| `RAILWAY_HEALTHCHECK_TIMEOUT_SEC` | `300` |
| `JIRA_URL` | optional, unset |
| `CONFLUENCE_URL` | optional, unset |
| `READ_ONLY_MODE` | optional, unset |
| `ATLASSIAN_OAUTH_ENABLE` | optional, unset |

## Notes

- **Stateless, single service, official image unmodified — no wrapper, no volume.** Everything is env-configured:
  `TRANSPORT=streamable-http`, `PORT=9000`, `STATELESS=true` (the image entrypoint `mcp-atlassian` reads them, so no
  start command). MCP endpoint at `/mcp`; liveness `/healthz`.
- **Per-request Atlassian auth (no stored credential).** The multi-user `UserTokenMiddleware` requires an Atlassian
  credential in each `/mcp` request's `Authorization` header and returns 401 without one, so the endpoint cannot
  leak a global token. The MCP handshake works with any header; real Jira/Confluence calls need the caller's own
  valid token. Clients: `Authorization: Token <PAT>` (Server/DC) or `Bearer <OAuth>` (Cloud).
- **`PORT` = 9000** = the domain target port; the app reads `PORT`. Runs as a non-root user; no `RAILWAY_RUN_UID`
  (stateless, no volume).
- Optional deploy inputs to connect an Atlassian instance: `JIRA_URL`, `CONFLUENCE_URL`, `ATLASSIAN_OAUTH_ENABLE`,
  `READ_ONLY_MODE`. The server runs and enforces the auth gate without them.
- **Live test scope:** health + the 401 auth gate + the MCP handshake/tool catalog are verified; actual Jira ops
  need the user's Atlassian token (out of scope, per the per-request model).

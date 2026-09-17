# Architecture

## Service graph

```
        Railway HTTPS edge
              │
              ▼
   ┌─────────────────────────────────────────────┐
   │  mcp  (public domain :9000)                  │  stateless — no volume, no database
   │  mcp-atlassian over streamable-HTTP:         │
   │   - MCP endpoint   POST /mcp  (per-request   │
   │                    Atlassian credential)     │
   │   - liveness       GET  /healthz  (no auth)  │
   └─────────────────────────────────────────────┘
              ▲
              │ Authorization: Token <PAT>  /  Bearer <OAuth>
        MCP clients (Claude, Cursor, …) → your Jira / Confluence
```

One stateless service. mcp-atlassian is configured entirely through environment variables; there is nothing to
build and no data to persist.

## The mcp service

- Image: the official `ghcr.io/sooperset/mcp-atlassian`, pinned by digest, used unmodified.
- **Transport:** `TRANSPORT=streamable-http` serves the MCP endpoint at `/mcp`. `STATELESS=true` keeps no session
  state between requests, which suits an ephemeral, horizontally scalable deployment.
- **Port:** the server reads `PORT` (set to `9000`); the public domain's target port is `9000` and the health check
  is `/healthz`.
- **Authentication (per request).** In this multi-user HTTP mode, a `UserTokenMiddleware` requires an Atlassian
  credential in each `/mcp` request's `Authorization` header and rejects requests without one (`401`). The MCP
  handshake (`initialize`, `tools/list`) works once any credential header is present; an actual Jira/Confluence
  operation uses that credential and therefore reflects that user's own permissions. No global Atlassian token is
  configured on the server.
- **Runs as a non-root user** and keeps no state, so no volume and no `RAILWAY_RUN_UID` are needed.

## Connecting your Atlassian

- **Server/Data Center:** set `JIRA_URL`/`CONFLUENCE_URL`; users send `Authorization: Token <PAT>`.
- **Cloud:** set `ATLASSIAN_OAUTH_ENABLE=true`; users send `Authorization: Bearer <OAuth access token>`.

These are optional deploy-time variables; the server runs without them and enforces the auth gate regardless.

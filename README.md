# mcp-atlassian on Railway

A one-click [Railway](https://railway.com) template that runs [mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
as a **remote MCP server for Jira and Confluence** over streamable-HTTP. Point your MCP client (Claude, Cursor, and
others) at your Railway URL and give it access to your Atlassian tools. The server is **stateless** and
**multi-user**: each request carries its own Atlassian credential, and requests without one are rejected.

This is a community-maintained template and is not affiliated with the mcp-atlassian project or with Atlassian.

- **Image:** the official `ghcr.io/sooperset/mcp-atlassian`, pinned by digest, used unmodified — see
  [UPSTREAM.md](UPSTREAM.md)

## What you get

- One stateless service exposing the MCP endpoint at `https://<your-domain>/mcp` (streamable-HTTP), plus a
  credential-free `/healthz` for liveness.
- **Per-request authentication.** Every `/mcp` request must carry an Atlassian credential in the `Authorization`
  header; a request without one is rejected (`401`). No global Atlassian token is stored on the server, so the
  endpoint cannot leak one operator's access to another.
- All Jira and Confluence toolsets, ready for your MCP client.

## Connect it to your Atlassian

Pick the model that matches your Atlassian:

- **Server / Data Center (PAT):** set `JIRA_URL` and/or `CONFLUENCE_URL` to your instance, then have each user send
  `Authorization: Token <their-personal-access-token>`.
- **Cloud (OAuth 2.0):** set `ATLASSIAN_OAUTH_ENABLE=true`, then have each user send
  `Authorization: Bearer <their-oauth-access-token>`.

See the upstream [Authentication](https://mcp-atlassian.soomiles.com/docs/authentication) and
[HTTP Transport](https://mcp-atlassian.soomiles.com/docs/http-transport) docs for obtaining tokens and per-client
setup.

## Use it in an MCP client

```jsonc
{
  "mcpServers": {
    "atlassian": {
      "url": "https://<your-domain>/mcp",
      "headers": { "Authorization": "Token <YOUR_PERSONAL_ACCESS_TOKEN>" }
    }
  }
}
```

## Security

- Consider `READ_ONLY_MODE=true` for a shared, exploratory endpoint (exposes only read tools).
- The server never holds a global Atlassian credential; each caller uses their own. See [SECURITY.md](SECURITY.md).

## Repository layout

| Path | What |
|---|---|
| `compose.yaml` | Local test topology (the official image, streamable-HTTP) |
| `tests/` | Static, smoke (auth gate + MCP handshake), restart-resilience, and live (HTTPS) tests |
| `marketplace/OVERVIEW.md` | The marketplace overview shown on the template page |
| `RAILWAY_TEMPLATE.md` | The exact published template configuration |
| `UPSTREAM.md` · `SECURITY.md` · `ARCHITECTURE.md` · `MAINTENANCE.md` | Reference docs |

## Local development

```bash
docker compose up          # run the official image over streamable-HTTP
tests/smoke.sh             # healthz, the 401 auth gate, and the MCP handshake
```

## Licence

The template's own files are MIT (`LICENSE`). mcp-atlassian keeps its own licence; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

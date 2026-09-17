# Marketplace audit

A record of the diligence behind publishing this template.

## Identity

- Template: **mcp-atlassian** — a remote MCP server for Jira and Confluence.
- Upstream: [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian), MIT, active (~5.9k stars).

## Licence

- MIT (`licenses/MCP-ATLASSIAN-LICENSE`); redistribution as a template is permitted. The official image is used
  unmodified; there is no wrapper. See `THIRD_PARTY_NOTICES.md`.

## Security review

- **No stored Atlassian credential.** The multi-user HTTP mode requires a per-request Atlassian credential and
  rejects requests without one (`401`), so the endpoint cannot leak a global token. Verified live.
- **Stateless.** No volume, no database, no secret at rest.
- **Reproducible.** The image is pinned by digest. The compose sets no credentials.

## Scope of the live test

mcp-atlassian's actual value — reading and writing Jira/Confluence — requires a real Atlassian token, which is the
caller's own credential in this per-request model. The tests therefore verify what the template is responsible for:
the server is healthy, the `/mcp` endpoint rejects unauthenticated requests, and the MCP handshake and tool catalog
work once a credential header is present. Exercising real Atlassian operations is the user's responsibility with
their own token.

## Reproducibility & tests

- `tests/static.sh` (14 checks): syntax, shellcheck, compose shape, digest pin, transport/stateless config, secret
  scan.
- `tests/smoke.sh` (5 checks): readiness, the `/mcp` 401 auth gate (with the reason), and the MCP handshake.
- `tests/persistence.sh` (3 checks): restart resilience (stateless — the server comes back and the handshake works).
- `tests/railway-smoke.sh`: the same flows over HTTPS against the deployed template.
- CI runs static + smoke + persistence on every push (no image build — the official image is used unmodified).

## Deploy-time inputs

- None required — the server runs out of the box and enforces the auth gate.
- Optional: `JIRA_URL`/`CONFLUENCE_URL` (Server/DC), `ATLASSIAN_OAUTH_ENABLE` (Cloud), `READ_ONLY_MODE`. Using the
  server needs each caller's own Atlassian token.

## Verdict

Shippable. A self-contained, reproducible, stateless remote MCP server for Jira/Confluence whose auth gate and MCP
protocol are verified on a live Railway deployment.

# Deploy and Host mcp-atlassian on Railway

mcp-atlassian is an open-source Model Context Protocol (MCP) server for Atlassian Jira and Confluence: it exposes
your Atlassian tools to MCP clients like Claude and Cursor. This template deploys it as a remote, stateless MCP
server over HTTP, so your AI clients can reach your Atlassian tools from anywhere. It is a community-maintained
template and is not affiliated with the mcp-atlassian project or with Atlassian.

## About Hosting mcp-atlassian

mcp-atlassian runs as a single stateless process that serves the MCP protocol over streamable-HTTP. In this
multi-user mode it holds no global Atlassian credential — instead every request must carry the caller's own
Atlassian credential in the `Authorization` header, and a request without one is rejected. That keeps the endpoint
from leaking one operator's access to another, but it also means the server must always enforce that gate when
exposed on the internet.

This template runs mcp-atlassian on Railway over streamable-HTTP in stateless mode, with the per-request
authentication gate enforced, the port and health check wired, and no secrets stored on the server. It runs the
official image unmodified, pinned by digest.

## Common Use Cases

- Giving your team's AI clients (Claude, Cursor, and other MCP clients) access to Jira and Confluence from a single
  shared, remote endpoint.
- A per-user Atlassian MCP gateway where each caller authenticates with their own token and sees their own
  permissions.
- A read-only Atlassian knowledge endpoint for AI assistants (with `READ_ONLY_MODE`).

## Dependencies for mcp-atlassian Hosting

- Nothing external to run the server — it is a single stateless service.
- To do anything useful, each caller provides their own Atlassian credential (a Personal Access Token for
  Server/Data Center, or an OAuth 2.0 access token for Cloud).

### Deployment Dependencies

- mcp-atlassian: https://github.com/sooperset/mcp-atlassian (MIT)
- Template repository and tests: https://github.com/youssefsiam38/mcp-atlassian-railway

### Implementation Details

The server runs upstream's official image, pinned by digest and unmodified, configured through environment
variables: `TRANSPORT=streamable-http` serves the MCP endpoint at `/mcp`, `STATELESS=true` keeps no session state,
and `PORT` (9000) is aligned with the public domain and the `/healthz` check. The multi-user middleware requires a
per-request Atlassian credential and rejects unauthenticated requests, so no global Atlassian token is stored. The
server runs as a non-root user and keeps no state, so there is no volume. Optional variables let you point it at
your Atlassian instance (`JIRA_URL`, `CONFLUENCE_URL`), enable Cloud OAuth (`ATLASSIAN_OAUTH_ENABLE`), or restrict
it to read tools (`READ_ONLY_MODE`).

Tested in CI and on a live deployment of this template: the server is healthy, the `/mcp` endpoint rejects a request
that carries no Atlassian credential, and the MCP handshake and tool catalog work once a credential header is
present.

After deploying, point your MCP client at `https://<your-domain>/mcp` with an `Authorization` header carrying your
Atlassian token (`Token <PAT>` for Server/Data Center, or `Bearer <OAuth>` for Cloud).

## Why Deploy mcp-atlassian on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you
don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying mcp-atlassian on Railway, you are one step closer to supporting a complete full-stack application with
minimal burden. Host your servers, databases, AI agents, and more on Railway.

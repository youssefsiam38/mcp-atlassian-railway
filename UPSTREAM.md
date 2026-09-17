# Upstream and pinned versions

This template runs **mcp-atlassian** from its official image, pinned by digest. There is no wrapper image — the
application is used unmodified and configured entirely through environment variables.

## mcp-atlassian

- Project: https://github.com/sooperset/mcp-atlassian
- Docs: https://mcp-atlassian.soomiles.com
- Licence: MIT (`licenses/MCP-ATLASSIAN-LICENSE`)
- Official image: `ghcr.io/sooperset/mcp-atlassian`
- Pinned: `ghcr.io/sooperset/mcp-atlassian:0.23.1`
  - digest `sha256:5b7c9b64d4eb3210cab74be8bf3e6aeea9ed14f3042dc59ba5c5287bd4dbe466`

## Refreshing a digest

```bash
docker buildx imagetools inspect ghcr.io/sooperset/mcp-atlassian:<tag> --format '{{json .Manifest}}' | jq -r .digest
```

Update the pins here, in `compose.yaml`, and in `_audit/spec_mcp_atlassian.py`, then re-run the tests and re-point
the template at the new tag. See `MAINTENANCE.md`.

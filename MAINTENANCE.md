# Maintenance

## Updating to a new upstream version

1. **Bump the pin.** Get the new digest (see `UPSTREAM.md`) and update `compose.yaml` and
   `_audit/spec_mcp_atlassian.py`, and re-point the template's `mcp` image at the new tag.
2. **Run the tests locally.**
   ```bash
   tests/static.sh
   tests/smoke.sh
   tests/persistence.sh
   ```
3. **Re-verify on Railway.** Re-run the clean-room deploy + `tests/railway-smoke.sh` before updating the published
   template.

There is no wrapper image to build or publish — the template runs the official image unmodified, so CI only runs
the tests.

## Rebuilding the Railway template from scratch

The exact configuration is in `RAILWAY_TEMPLATE.md`. The generator spec is `_audit/spec_mcp_atlassian.py`; the kit
in `_audit/` (`tplkit.py`) builds a skeleton, patches the template, and runs a clean-room deploy. The service has no
volume (stateless).

## Gotchas worth remembering

- **Everything is env-configured.** `TRANSPORT=streamable-http`, `PORT=9000`, `STATELESS=true` — the image's
  entrypoint (`mcp-atlassian`) reads these, so no start command is needed. Health check `/healthz`; MCP at `/mcp`.
- **The `/mcp` endpoint is auth-gated** by the multi-user middleware: no `Authorization` header → `401`. The
  handshake works with any header; real Atlassian calls need a valid token.
- **Stateless — no volume, no `RAILWAY_RUN_UID`.** The server keeps no state and runs as a non-root user.
- **The marketplace OVERVIEW needs `### Deployment Dependencies` as an H3** or Railway's publish rejects the readme.

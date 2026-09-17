#!/usr/bin/env bash
# shellcheck disable=SC2015
# Smoke test: run the server, then verify liveness, that the /mcp endpoint rejects requests with no Atlassian
# credential (401), and that the MCP handshake and tool catalog work once a credential header is present. (Actual
# Jira/Confluence operations need a real Atlassian token — the caller's — and are not exercised here.)
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"

STARTED=0
if [ "${MCP_REUSE_STACK:-0}" != "1" ]; then
  section "bring the stack up"
  compose up -d --pull always >/dev/null 2>&1 || die "compose up failed"
  STARTED=1
  trap 'compose logs --no-color --tail 100 || true; [ "$STARTED" = 1 ] && compose down --remove-orphans >/dev/null 2>&1 || true; rm -rf "$TEST_TMP"' EXIT
else
  trap 'rm -rf "$TEST_TMP"' EXIT
fi

section "liveness"
wait_for_code "$APP_URL/healthz" 200 180 && pass "/healthz returns 200 (no auth)" || die "server never became healthy"

section "the /mcp endpoint requires an Atlassian credential"
assert_eq "POST /mcp without a credential is rejected" "401" \
  "$(mcp_post_code '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}' --no-auth)"
assert_contains "the rejection explains why" "Atlassian credentials" \
  "$(mcp_post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' --no-auth)"

section "the MCP handshake works with a credential header"
init=$(mcp_post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}')
assert_contains "initialize returns the Atlassian MCP server info" '"protocolVersion"' "$init"
assert_contains "the server advertises tool support" '"tools"' "$init"

summary

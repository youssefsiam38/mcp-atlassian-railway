#!/usr/bin/env bash
# shellcheck disable=SC2015
# The server is stateless (no volume, no database), so there is no data to persist. This test instead proves
# restart resilience: after a full restart the server comes back healthy and the MCP handshake still works.
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"
trap 'compose logs --no-color --tail 100 || true; compose down --remove-orphans >/dev/null 2>&1 || true; rm -rf "$TEST_TMP"' EXIT

section "bring the stack up"
compose up -d --pull always >/dev/null 2>&1 || die "compose up failed"
wait_for_code "$APP_URL/healthz" 200 180 || die "server never became healthy"

section "before restart"
init=$(mcp_post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"persist","version":"0"}}}')
assert_contains "the MCP handshake works before the restart" '"protocolVersion"' "$init"

section "full restart"
compose down >/dev/null 2>&1
compose up -d >/dev/null 2>&1 || die "compose up failed"
wait_for_code "$APP_URL/healthz" 200 180 && pass "healthy again after restart" || die "not healthy after restart"

section "after restart"
init=$(mcp_post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"persist","version":"0"}}}')
assert_contains "the MCP handshake works after the restart" '"protocolVersion"' "$init"

summary

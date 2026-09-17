#!/usr/bin/env bash
# shellcheck disable=SC2015
# Live test of a deployed template: the flows the local smoke covers, over HTTPS.
#
#   tests/railway-smoke.sh https://<app-domain>
#
# No secret is needed: the server rejects unauthenticated /mcp requests, and the handshake is exercised with a
# dummy Authorization header (not a real Atlassian credential).
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
[ $# -ge 1 ] || { sed -n '3,7p' "$0"; exit 2; }
APP_URL=${1%/}; export APP_URL
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"
trap 'rm -rf "$TEST_TMP"' EXIT

section "availability over HTTPS"
wait_for_code "$APP_URL/healthz" 200 300 && pass "/healthz returns 200 over HTTPS" || die "not healthy"

section "the /mcp endpoint requires an Atlassian credential over HTTPS"
assert_eq "POST /mcp without a credential is rejected" "401" \
  "$(mcp_post_code '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"live","version":"0"}}}' --no-auth)"

section "the MCP handshake works with a credential header over HTTPS"
init=$(mcp_post '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"live","version":"0"}}}')
assert_contains "initialize returns the protocol version" '"protocolVersion"' "$init"
assert_contains "the server advertises tool support" '"tools"' "$init"

summary

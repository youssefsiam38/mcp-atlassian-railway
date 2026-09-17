#!/usr/bin/env bash
# shellcheck disable=SC2015
# Shared helpers for mcp-atlassian-railway tests. Source this file; do not execute it.
# The server is stateless and multi-user: every /mcp request must carry an Atlassian credential
# (Authorization header). No credential -> 401. The MCP handshake works with any Authorization header;
# actual Jira/Confluence calls need a real token (the caller's), which the tests do not exercise.

: "${APP_URL:=http://localhost:${MCP_TEST_PORT:-19000}}"
: "${TEST_TIMEOUT:=300}"
# A dummy Authorization header so the handshake passes the auth gate. It is NOT a real Atlassian credential.
: "${MCP_DUMMY_AUTH:=Token test-only-not-a-real-atlassian-token}"

TEST_TMP="${TEST_TMP:-$(mktemp -d)}"
export TEST_TMP
_PASS=0; _FAIL=0

pass() { _PASS=$((_PASS+1)); printf '  PASS  %s\n' "$*"; }
fail() { _FAIL=$((_FAIL+1)); printf '  FAIL  %s\n' "$*" >&2; }
die()  { printf 'FATAL: %s\n' "$*" >&2; exit 1; }
section() { printf '\n== %s ==\n' "$*"; }
summary() { printf '\n%d passed, %d failed\n' "$_PASS" "$_FAIL"; [ "$_FAIL" -eq 0 ]; }

assert_eq() { if [ "$2" = "$3" ]; then pass "$1 ($3)"; else fail "$1: expected [$2] got [$3]"; fi; }
assert_contains() { if grep -q -- "$2" <<<"$3"; then pass "$1"; else fail "$1: missing [$2]"; fi; }

http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 30 "$@" || true; }

wait_for_code() {
  local url=$1 want=$2 timeout=${3:-$TEST_TIMEOUT} start code
  start=$(date +%s)
  while :; do
    code=$(http_code "$url")
    [ "$code" = "$want" ] && return 0
    if [ $(( $(date +%s) - start )) -ge "$timeout" ]; then printf 'timed out waiting for %s -> %s (last %s)\n' "$url" "$want" "$code" >&2; return 1; fi
    sleep 3
  done
}

compose() { docker compose -f "$REPO_ROOT/compose.yaml" "$@"; }

# mcp_post BODY [--no-auth] -> prints the raw response of POST /mcp
mcp_post() {
  local body=$1 mode=${2:-auth} auth=(-H "Authorization: $MCP_DUMMY_AUTH")
  [ "$mode" = "--no-auth" ] && auth=()
  curl -s --max-time 60 -X POST "$APP_URL/mcp" "${auth[@]}" \
    -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' --data "$body"
}
mcp_post_code() {
  local body=$1 mode=${2:-auth} auth=(-H "Authorization: $MCP_DUMMY_AUTH")
  [ "$mode" = "--no-auth" ] && auth=()
  curl -s -o /dev/null -w '%{http_code}' --max-time 60 -X POST "$APP_URL/mcp" "${auth[@]}" \
    -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' --data "$body" || true
}

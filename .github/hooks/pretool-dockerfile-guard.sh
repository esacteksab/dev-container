#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"

# Only gate tool calls that appear to target Dockerfile edits.
if ! grep -q 'Dockerfile' <<<"$payload"; then
  cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Not a Dockerfile edit"
  }
}
JSON
  exit 0
fi

# Deny obviously unsafe Dockerfile edit attempts. This is a conservative string check
# against tool input because PreToolUse runs before file contents are changed.
unsafe_patterns='latest|curl[[:space:]]+[^|]*\|[[:space:]]*(sh|bash)|wget[[:space:]]+[^|]*\|[[:space:]]*(sh|bash)|FROM[[:space:]]+[^ @]+:[^ @]+[[:space:]]*$'

if grep -Eiq "$unsafe_patterns" <<<"$payload"; then
  cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked Dockerfile edit: detected unsafe pattern (floating tags or pipe-to-shell). Use pinned versions/SHA and approved install patterns."
  }
}
JSON
  exit 2
fi

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Dockerfile edit passed pre-tool guard"
  }
}
JSON

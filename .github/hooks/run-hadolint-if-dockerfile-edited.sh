#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"

# Only run hadolint when the tool event touched Dockerfile.
if ! grep -q 'Dockerfile' <<<"$payload"; then
  echo '{"continue": true}'
  exit 0
fi

if make lint >/tmp/hadolint-hook.log 2>&1; then
  echo '{"continue": true, "systemMessage": "Dockerfile lint passed (hadolint)."}'
  exit 0
fi

lint_output="$(tail -n 80 /tmp/hadolint-hook.log)"
system_message_json="$(
  printf 'hadolint reported violations:\n%s' "$lint_output" | \
    python3 -c 'import json, sys; print(json.dumps(sys.stdin.read()))'
)"

cat <<JSON
{
  "decision": "block",
  "reason": "Dockerfile lint failed. Fix pinning/security issues before continuing.",
  "systemMessage": ${system_message_json}
}
JSON

exit 2

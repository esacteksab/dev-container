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

lint_output="$(tail -n 80 /tmp/hadolint-hook.log | sed 's/"/\\"/g')"

cat <<JSON
{
  "decision": "block",
  "reason": "Dockerfile lint failed. Fix pinning/security issues before continuing.",
  "systemMessage": "hadolint reported violations:\n${lint_output}"
}
JSON

exit 2

#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker is required to run container-structure-test locally" >&2
  exit 1
fi

CST_BIN=""
TMP_DIR=""
cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

if command -v container-structure-test >/dev/null 2>&1; then
  CST_BIN="$(command -v container-structure-test)"
else
  TMP_DIR="$(mktemp -d)"
  CST_BIN="$TMP_DIR/container-structure-test"
  curl -fsSL -o "$CST_BIN" \
    https://github.com/GoogleContainerTools/container-structure-test/releases/latest/download/container-structure-test-linux-amd64
  chmod +x "$CST_BIN"
fi

IMAGE_TAG="dev-container:local-ci"
docker build -t "$IMAGE_TAG" .
"$CST_BIN" test --image "$IMAGE_TAG" --config container-structure-test.yaml

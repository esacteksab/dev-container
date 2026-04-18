#!/usr/bin/env bash
set -euo pipefail

workspace_folder="${1:-}"

if [[ -z "$workspace_folder" ]]; then
    echo "error: workspace path is required" >&2
    exit 1
fi

if ! command -v docker > /dev/null 2>&1; then
    echo "warning: docker not found; skipping stale devcontainer cleanup" >&2
    exit 0
fi

# Match current and legacy dev container labels.
mapfile -t container_ids < <(
    {
        docker ps -aq --filter "label=devcontainer.local_folder=$workspace_folder"
        docker ps -aq --filter "label=vsch.local.folder=$workspace_folder"
    } | awk 'NF {print $0}' | sort -u
)

if [[ ${#container_ids[@]} -eq 0 ]]; then
    exit 0
fi

for container_id in "${container_ids[@]}"; do
    # Ignore failures here and rely on the wait loop below.
    docker rm -f "$container_id" > /dev/null 2>&1 || true

    # Docker can briefly report "removal already in progress"; wait until inspect fails.
    for _ in {1..60}; do
        if ! docker inspect --type container "$container_id" > /dev/null 2>&1; then
            break
        fi
        sleep 1
    done

done

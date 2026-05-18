---
description: "Use when adding, updating, or removing tool versions in Dockerfile, container-structure-test.yaml, requirements.txt, or package.json. Enforces version pinning, SHA digest, and cross-file sync rules."
applyTo: ["Dockerfile", "container-structure-test.yaml", "requirements.txt", "package.json"]
---

# Version Pinning

## Docker Base Images

- All `FROM` directives **must** use a SHA256 digest: `image:tag@sha256:<digest>`
- Never use `latest`, a floating major/minor tag, or a bare tag without a digest
- All stages in a multi-stage build must pin the same digest for the same base image

## COPY --from= (Distroless / External Images)

- `COPY --from=<image>:<tag>` references **must** use an exact version tag — never `latest`
- When possible, use a SHA256 digest here too: `COPY --from=image:tag@sha256:<digest>`

## Binary Tools (curl / wget downloads)

- Every tool fetched via `curl` or `wget` **must** specify an exact version in the URL or filename
- Never interpolate a floating variable like `LATEST` or `$(curl ... /latest)`
- Verify checksums after download when the upstream project publishes them (`.sha256`, `.checksums`, etc.)

## Documented Exceptions

`gh` (GitHub CLI) and `mise` are intentionally floating. They must remain the only exceptions. Do not add new floating-version tools without explicit justification.

## Cross-File Version Sync

When a tool version changes in the `Dockerfile`:

1. Update the version assertion in `container-structure-test.yaml` to match
2. Never leave `container-structure-test.yaml` asserting a version that differs from the `Dockerfile`

The test file is the runtime source of truth — a passing test proves the pinned version is actually present.

## requirements.txt

- Pin Python packages with `==` (exact): `pre-commit==4.6.0`
- Never use `>=`, `~=`, or an unpinned package name

## package.json / pnpm-lock.yaml

- `pnpm-lock.yaml` is committed and is the source of truth for installed versions
- Do not edit `pnpm-lock.yaml` manually — run `pnpm install` to regenerate it
- Prefer exact versions in `package.json` `devDependencies`; avoid loose ranges (`*`, `x`)

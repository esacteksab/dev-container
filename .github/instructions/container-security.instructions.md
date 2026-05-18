---
description: "Use when editing the Dockerfile. Enforces container security best practices: SHA-pinned images, non-root user, minimal attack surface, verified downloads, and clean layer hygiene."
applyTo: "Dockerfile"
---

# Container Security

## Base Image

- Always use a SHA256-pinned base image — no mutable tags, ever
- Update the digest intentionally after verifying the new image with `trivy image`

## Non-Root User

- The final image **must** run as `devcontainer` (UID/GID 1000) — never as root
- Any file or directory created in `RUN` that the user needs must be `chown`ed to `${USER_UID}:${USER_GID}` in the same layer
- Use `install -d -m 0755 -o "${USER_UID}" -g "${USER_GID}"` when creating directories for the user

## apt Install Hygiene

- Every apt install must use `--no-install-recommends`
- The APT config lines disabling suggests and recommends must be set before any `apt-get install`:
  ```
  echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
  echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
  ```
- Clean apt artifacts in the **same** `RUN` layer they are created in:
  ```
  && apt-get clean && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /var/log/apt/* /var/log/dpkg.log
  ```

## Third-Party apt Repositories

- Must use GPG key verification via the keyrings pattern (`/etc/apt/keyrings/`)
- GPG keyring file permissions: `chmod go+r`
- Never add an unsigned repository

## Binary Downloads (curl / wget)

- Avoid `curl | sh` or `wget | sh` for version-pinned tools — prefer:
  1. Direct binary download with `wget -nv -O` or `curl -fsSL -o`
  2. `COPY --from=<image>:<version>` to pull a prebuilt binary from a versioned image
- Verify checksums when the upstream publishes them
- `mise` is the only accepted `curl | sh` pattern (it is intentionally floating and not a pinned binary)

## RUN Command Safety

- All `RUN` commands must start with `set -eux` to fail fast on any error and expose executed commands

## Multi-Stage Build

- Build/compile steps belong in named stages; only copy the final artifact to the final stage
- Do not copy entire stage filesystems — copy only the specific binary or directory needed
- Use `COPY --link` when the layer has no dependency on prior layers (faster rebuilds)

## Environment Variables

- Only set `ENV` variables that are required at **runtime**
- Build-time values that do not need to persist in the image should use `ARG`, not `ENV`
- Do not embed secrets, tokens, or credentials in any layer

## Image Scanning

- Run `trivy image <image>` before publishing a new image version
- Address CRITICAL and HIGH CVEs before pushing; document intentional exceptions

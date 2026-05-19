# Dev Container — Agent Instructions

A base VS Code dev container image built on Ubuntu 24.04, published to Docker Hub as `esacteksab/dev-container`. It provides common tooling (linters, formatters, pre-commit, language runtimes) for use across multiple projects and languages.

## Build & Test Commands

| Command                   | Purpose                                                           |
| ------------------------- | ----------------------------------------------------------------- |
| `make build`              | Build and push image with date + git-tag labels                   |
| `make test`               | Run container structure tests via `container-structure-test.yaml` |
| `make lint`               | Lint the Dockerfile with hadolint (ignores DL3008)                |
| `make devcontainer-clean` | Remove stale dev container instances for this workspace           |

If Docker reports `removal of container <id> is already in progress`, run `make devcontainer-clean`.

## Dockerfile Conventions

- **Base image is SHA256-pinned** (`ubuntu:24.04@sha256:...`) for reproducibility. Update the digest intentionally, not casually.
- **Multi-stage build**: separate `python`, `gh`, `node`, and final stages; binaries are copied into the final stage to minimize image size.
- **Binary tools** (zizmor, uv, trivy) are fetched at exact pinned versions via `curl`/`wget`. Go is sourced via `COPY --from=golang:...`, and Go and Node runtimes are version-locked.
- `devcontainer` user is UID/GID 1000. Files and permissions must reflect this.

## Tool Version Pinning Rule

**When you update a tool version in the Dockerfile, you must also update the version assertion in [`container-structure-test.yaml`](container-structure-test.yaml).** Both files must stay in sync — the test file is the source of truth for what's expected at runtime.

Currently pinned versions (see Dockerfile for authoritative values):

| Tool       | Version |
| ---------- | ------- |
| Go         | 1.26.2  |
| Node       | v22     |
| pnpm       | 10.33.0 |
| pre-commit | 4.6.0   |
| uv         | 0.11.7  |
| trivy      | 0.70.0  |
| zizmor     | 1.24.1  |
| Prettier   | 3.8.3   |

GitHub CLI (`gh`) and `mise` are intentionally floating (latest).

## Formatting

Formatting uses **Prettier via pnpm** with plugins for shell, TOML, Go templates, and pkg files:

```bash
pnpm prettier --write <file>
```

Run `pnpm install` first if node_modules are missing. The `pnpm-lock.yaml` is committed — do not change the lockfile manually.

## Python Dependencies

Python packages (just `pre-commit` for now) are in [`requirements.txt`](requirements.txt) and installed with `--break-system-packages`. Add new Python tooling here.

## CI Workflows

- **[build.yml](.github/workflows/build.yml)**: Scheduled weekly (Wed 14:14 UTC) — builds and pushes `latest` + date-tagged image to Docker Hub.
- **[pr-build.yml](.github/workflows/pr-build.yml)**: Triggered on PRs changing `Dockerfile`, `zshrc`, `vimrc`, `package.json`, `pnpm-lock.yaml`, or `.devcontainer/devcontainer.json`. Builds and runs container structure tests.
- **[hadolint.yml](.github/workflows/hadolint.yml)**: Dockerfile linting on PRs.
- **[pre-commit.yml](.github/workflows/pre-commit.yml)**: Reusable workflow from `esacteksab/.github`.

## Repository Layout

```
Dockerfile                   # Multi-stage image definition
container-structure-test.yaml # Tool presence/version tests
requirements.txt             # Python tooling (pre-commit)
package.json / pnpm-lock.yaml # Prettier + plugins
vimrc / zshrc                # Config files copied into image
scripts/
  build-container.sh         # Builds + pushes image
  run-container-structure-test.sh
  cleanup-devcontainer.sh
.github/workflows/           # CI workflows
```

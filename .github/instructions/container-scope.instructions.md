---
description: "Use when deciding whether to add a tool, runtime, configuration file, or VS Code extension to this dev container base image. Enforces reusability principles, lowest-common-denominator tooling, and project-level customization points."
---

# Container Scope & Reusability

## Purpose

This image is a **shared base** used across many repos, projects, and languages. Every addition must justify its presence across that full breadth. When in doubt, leave it out.

## What Belongs in the Base Image

A tool belongs here if it is **universally useful regardless of language or project type**:

| Category | Examples |
|----------|---------|
| Core VCS & shell | `git`, `zsh`, `make` |
| Universal utilities | `jq`, `direnv`, `curl`, `openssh-client`, `ca-certificates` |
| Security scanning | `trivy`, `zizmor` |
| Hook framework | `pre-commit` |
| Runtime version manager | `mise` |
| Editor | `vim` |
| Formatters that span languages | `prettier` (with plugins for sh, TOML, go-template) |

Language runtimes (Go, Node, Python) are included because they are common enough across projects to be worth the image size trade-off.

## What Does NOT Belong in the Base Image

- Project-specific linters, test runners, or build tools
- Language-specific package managers beyond what's already present (`uv`, `pnpm`)
- Frameworks, ORMs, CLIs for a single project
- VS Code extensions (those go in the consuming repo's `devcontainer.json`)
- Anything that is only useful in one repo or one language ecosystem

## Project-Level Customization Points

Use these mechanisms in the **consuming repo**, not the base image:

| Need | Where to configure |
|------|--------------------|
| Runtime version override | `.mise.toml` in the project root |
| Project-specific tool install | `postCreateCommand` in `.devcontainer/devcontainer.json` |
| Project-specific VS Code extensions | `customizations.vscode.extensions` in `devcontainer.json` |
| Project-specific pre-commit hooks | `.pre-commit-config.yaml` in the project root |
| Extra Python packages | `requirements.txt` in the project, installed via `postCreateCommand` |
| Node packages | `package.json` + `pnpm install` in `postCreateCommand` |

## Adding a New Tool: Decision Checklist

Before adding a tool to the `Dockerfile`, confirm:

1. **Universal?** — Is it useful in ≥3 different language ecosystems?
2. **Pinnable?** — Can it be version-pinned (exact version or SHA)?
3. **Auditable?** — Is it available from a verifiable source (GitHub Releases, official Docker image, signed apt repo)?
4. **Lightweight?** — Does it keep the image size reasonable (prefer a single static binary over a full runtime)?
5. **Not project-specific?** — Would it be surprising to find this in a Python-only repo or a Go-only repo?

If any answer is No, configure it at the project level via `mise` or `postCreateCommand` instead.

## mise as the Project-Level Escape Hatch

`mise` is intentionally floating (latest) because its value is precisely to manage tool versions *per project*. Use it:

- In consuming repos: define a `.mise.toml` to pin project-specific runtime versions
- Do not embed tool versions that belong in `.mise.toml` into the base `Dockerfile`

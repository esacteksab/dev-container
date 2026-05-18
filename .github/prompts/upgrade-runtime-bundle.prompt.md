---
description: "Upgrade a runtime bundle (for example Go, Node, or Python tooling) across all linked files and assertions in one coordinated change"
name: "Upgrade Runtime Bundle"
argument-hint: "<runtime> <new-version>"
agent: "agent"
---
Upgrade a linked runtime bundle using these arguments:
- runtime: $1
- new version: $2

Goal:
- Apply a coordinated upgrade for a runtime and all linked components so versions remain fully synchronized.

Required process:
1. Read and follow:
   - [Version pinning instructions](../instructions/version-pinning.instructions.md)
   - [Container security instructions](../instructions/container-security.instructions.md)
   - [Container scope instructions](../instructions/container-scope.instructions.md)
2. Identify the runtime bundle and all dependent references before editing. Include, as applicable:
   - Dockerfile ARG/ENV values and image tags
   - COPY --from image tags and digests
   - container-structure-test.yaml version assertions
   - requirements.txt and package.json entries
   - pnpm-lock.yaml if package manifests change
   - scripts and workflow files that pin or assert related versions
3. Update all linked references in one pass so no partial upgrade remains.
4. Preserve strict pinning policy (exact versions, immutable references, SHA digests where applicable).
5. Regenerate lockfiles via package manager commands rather than manual edits.
6. Run targeted validation and report outcomes.

Runtime bundle guidance:
- Go bundle example: Go version ARG, Go tarball URL, any Go image references, and Go assertion in container-structure-test.yaml.
- Node bundle example: NODE major/source setup, pnpm version, package manager metadata, and container-structure-test.yaml assertions.
- Python tooling bundle example: requirements.txt exact pins plus any test assertions for installed CLIs.

Validation minimum:
- make lint when Dockerfile changed
- make test when runtime assertions changed
- pnpm install when package.json changed

Output format:
- Bundle inventory found
- Files changed
- Validation commands and pass or fail status
- Risk notes and any deferred follow-ups

Constraints:
- No unrelated upgrades outside the selected bundle.
- Do not change floating-policy exceptions unless explicitly requested.
- If any linked component cannot be updated safely in this run, stop and explain why before making partial edits.

---
description: "Upgrade one tool version atomically across Dockerfile, container-structure-test.yaml, and lockfiles while preserving pinning and security rules"
name: "Upgrade Tool"
argument-hint: "<tool> <new-version>"
agent: "agent"
---
Upgrade a single tool to a new version using these arguments:
- tool: $1
- new version: $2

Task objective:
- Apply one atomic version bump so Dockerfile, runtime verification tests, and lockfiles remain in sync.

Required workflow:
1. Read and follow these instruction files before editing:
   - [Version pinning instructions](../instructions/version-pinning.instructions.md)
   - [Container security instructions](../instructions/container-security.instructions.md)
   - [Container scope instructions](../instructions/container-scope.instructions.md)
2. Find all occurrences of the target tool and current version in:
   - Dockerfile
   - container-structure-test.yaml
   - requirements.txt
   - package.json
   - pnpm-lock.yaml
3. Update only entries related to the requested tool.
4. Keep pinning strict:
   - exact versions for packages
   - SHA-pinned base images and immutable references when relevant
5. Maintain cross-file sync:
   - if Dockerfile version changes, update matching assertions in container-structure-test.yaml
6. If package manifests changed, regenerate lockfiles using the correct package manager rather than editing lockfiles manually.
7. Run relevant validation commands and report outcomes.

Validation expectations:
- Prefer the smallest validation set that proves correctness:
  - make lint when Dockerfile changed
  - make test when runtime tool assertions changed
  - pnpm install only when package.json changed

Output format:
- Summary of what changed
- Files updated
- Validation commands run and pass or fail status
- Any assumptions or follow-up actions

Constraints:
- Do not introduce unrelated upgrades.
- Do not relax any pinned versions.
- If requested tool is intentionally floating by policy, explain and stop unless explicitly asked to change policy.

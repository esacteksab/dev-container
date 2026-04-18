## Motivation

This is an experiment. An attempt to see if I can make repos less "fat" by leveraging VS Code's dev containers.

Very much a work in progress, I'm still figuring things out.

## Rebuild reliability

If Docker reports an error similar to `removal of container <id> is already in progress` during a dev container rebuild, run:

```bash
make devcontainer-clean
```

The repository now runs the same cleanup automatically through the dev container `initializeCommand`, which removes stale containers for this workspace and waits for removal to finish before the next create/rebuild step.

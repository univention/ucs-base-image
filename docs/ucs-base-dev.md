# Using `ucs-base-dev`

The container `ucs-base-dev` is intended to serve the needs during the
development for the case when packages from a branch of the `ucs` repository
are needed.

The intended usage consists of the following steps:

1. Use the `ucs-base-dev-${UCS_VERSION}` as a base image. It provides the
   needed GPG keys already and includes the utilities for the second step.
2. Add the branches to the APT sources via `ucs-dev-add-branch.sh`.

[This example](/docker/ucs-base/dev.Dockerfile.usage-example) does apply the steps.

# Container UCS Base

This project does build a few container images which are prepared so that UCS
packages can be installed.

It started based from a fragment which we saw being repeated over and over
across many of our `Dockerfile` files.

The images are tagged according to the following pattern:

```
ucs-base-${UCS_VERSION}:${IMAGE_TAG}
```

- `${UCS_VERSION}` is a value like `504`
- `${IMAGE_TAG}` is a tag generated from the CI run, e.g. `latest`, `branch-example`.

Be aware that the base containers do include the errata releases as well by
default. This means that your images will potentially change if they are built
again in the future.


## Status - Beta

We try to apply the DRY (Don't repeat yourself) principle. It is tagged as
"Beta" since we have only little experience so far with the approach.


## Contact

- Team SouvAP Dev
  - <johannes.bornhold.extern@univention.de>


## Example usage

```Dockerfile

FROM gitregistry.knut.univention.de/univention/customers/dataport/upx/container-ucs-base/ucs-base-504:latest AS ucs-base

RUN apt-get update \
    && apt-get --assume-yes --verbose-versions --no-install-recommends install \
      python3-univention-directory-manager-rest-client=10.* \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
```

## Development setup

There is no special setup needed. Use the plain `docker` CLI commands to work on
the container images:

```shell
# Build example
docker build --platform linux/amd64 --build-arg UCS_VERSION=503 docker/ucs-base -t wip

# Run a shell to inspect the result
docker run -it --rm wip bash
```

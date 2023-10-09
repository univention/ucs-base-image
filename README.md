# Container UCS Base

This project does build a few container images which are prepared so that UCS
packages can be installed.

It started based from a fragment which we saw being repeated over and over
across many of our `Dockerfile` files.

The images are tagged according to the following pattern:

```
`ucs-base-{500,501,502,503,504,505}` based on
`ucs-base-dev-{500,501,502,503,504,505}`
`ucs-base-test-{510,520}-dev`
```

All with `latest` and semantic-release `v0.6.0` or latest release.

Be aware that the base containers do include the errata releases as well by
default. This means that your images will potentially change if they are built
again in the future.

## Status - Beta

We try to apply the DRY (Don't repeat yourself) principle. It is tagged as
"Beta" since we have only little experience so far with the approach.


## Provided images

- `ucs-base-${UCS_VERSION}` allows to install published Univention packages.
- `ucs-base-dev-${UCS_VERSION}` and `ucs-base-dev-${UCS_VERSION}-test` have in
addition the key from `omar` installed and has a utility to add the sources of
a branch from the `ucs` repository.


## Example usage

```Dockerfile
FROM gitregistry.knut.univention.de/univention/customers/dataport/upx/container-ucs-base/ucs-base-502:latest AS ucs-base

RUN apt-get update \
    && apt-get --assume-yes --verbose-versions --no-install-recommends install \
      python3-univention-config-registry \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
```

### Entrypoint handling

The image contains the file `docker/entrypoint.sh` in `/entrypoint.sh`.
Ideally any derived containers should run it as follows:
```Dockerfile
ENTRYPOINT ["./entrypoint.sh"]
CMD ["/path/to/application", "--argument", "value"]
```

Any preparation of the environment can be done by copying a shell script
into the `/entrypoint.d/` folder.

Preferably the file names should follow the pattern of `[0-9][0-9]-name.(envsh|sh)`.
The number in the beginning determines the order in which the entrypoints are executed.

File whose names end with `.envsh` are `source`d (i.e. good for setting environment variables),
while those ending with `.sh` are running in a sub-shell.

Please do _not_ put a `99-run.sh` to run your application,
as this makes debugging tedious.
Instead define the `CMD` as above.
This way, anyone can `docker run ... bash` to enter a shell inside the prepared environment.

## Development setup

There is no special setup needed. Use the plain `docker` CLI commands to work on
the container images:

```shell
# Build example
docker build --platform linux/amd64 --build-arg UCS_VERSION=502 -t wip .

# Run a shell to inspect the result
docker run -it --rm wip bash
```

## Linting

You can run the pre-commit checker as follows:
```bash
docker compose run --rm pre-commit
```

## Contact

- Team SouvAP Dev
  - <johannes.bornhold.extern@univention.de>

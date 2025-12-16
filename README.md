# Disclaimer - Work in progress

The repository you are looking into is work in progress.

It contains proof of concept and preview builds in development created in context of the [openDesk](https://gitlab.opencode.de/bmi/souveraener_arbeitsplatz/info) project.

The repository's content provides you with first insights into the containerized cloud IAM from Univention, derived from the UCS appliance.

# Container UCS Base

This project does build a few container images which are prepared so that UCS
packages can be installed.

It started based from a fragment which we saw being repeated over and over
across many of our `Dockerfile` files.

The images are tagged according to the following patterns:

* `ucs-base` and `ucs-base-python` images include a build date for reproducibility:
  `<image-name>:<UCS-version>-build.<build-date>`
* `ucs-base-flex` images provide a rolling tag for the latest build of a given version:
  `<image-name>:<UCS-version>`

Where:
- `<image-name>` can be `ucs-base`, `ucs-base-flex`, or `ucs-base-python`.
- `<UCS-version>` is the version of the underlying UCS distribution (e.g., `5.0.10`, `5.2.1`, `5.2.2`, `5.2.4`).
- `<build-date>` is the date identifier when the image was built (e.g., `20250709`).

Example tags:

- `ucs-base:5.2.2-build.20250709`
- `ucs-base-python:5.2.2-build.20250709`
- `ucs-base-flex:5.2.2`

The `latest` tag will point to the most recent build of the default `ucs-base` image.

## Errata release handling

Be aware that the base containers do include the errata releases as well by
default. This means that your images will potentially change if they are built
again in the future. The date-based tagging helps to mitigate this by providing a stable tag for a specific build.


## Provided images

- `ucs-base-${UCS_VERSION}` allows to install published Univention packages.
- `ucs-base-dev-${UCS_VERSION}` have in addition the key from `omar` installed
and has a utility to add the sources of a branch from the `ucs` repository.


## Example usage

See the file `docker/ucs-base/Dockerfile.usage-example`.

### Entrypoint handling and the PID 1 duties

The image contains the file `docker/entrypoint.sh` in `/entrypoint.sh` and uses
the following default configuration:

```Dockerfile
ENTRYPOINT ["tini", "--", "/entrypoint.sh"]
```

This uses `tini` as the special process with PID 1 so that proper signal
handling is provided by default. For derived containers it is sufficient to
start the application via the `CMD` directive.

Derived containers which handle Signals properly and take care of zombie
processes should override this configuration as follows:

```Dockerfile
ENTRYPOINT ["/entrypoint.sh"]

# Run your application via CMD
CMD ["/path/to/application", "--argument", "value"]
```

### Extensibility of the entrypoint mechanism

Any preparation of the environment can be done by copying a shell script
into the `/entrypoint.d/` folder.

Preferably the file names should follow the pattern of `[0-9][0-9]-name.(envsh|sh)`.
The number in the beginning determines the order in which the entrypoints are executed.

If in doubt, use `50-` as the prefix so that it is easy to run scripts before or
after your script in derived containers for development or testing purposes.
Also be aware that the usage in the final environment may need special tweaks
which can be achieved by mounting scripts into this location.

File whose names end with `.envsh` are `source`d (i.e. good for setting environment variables),
while those ending with `.sh` are running in a sub-shell.

Please do _not_ put a `99-run.sh` to run your application, as this makes
debugging tedious. Instead define the `CMD` as above. This way, anyone can
`docker run ... bash` to enter a shell inside the prepared environment.

## Development setup

There is no special setup needed. Use the plain `docker` CLI commands to work on
the container images:

```shell
# Build example
docker build --platform linux/amd64 --build-arg UCS_VERSION=505 -t ucs-base:local ./docker

# Run a shell to inspect the result
docker run -it --rm wip bash
```

## Linting

You can run the pre-commit checker as follows:
```bash
docker compose run --rm pre-commit
```

## Contact

- Team Nubus Dev
  - <johannes.bornhold.extern@univention.de>
  - <conde-segovia.extern@univention.de>

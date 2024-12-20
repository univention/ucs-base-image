# Disclaimer - Work in progress

The repository you are looking into is work in progress.

It contains proof of concept and preview builds in development created in context of the [openDesk](https://gitlab.opencode.de/bmi/souveraener_arbeitsplatz/info) project.

The repository's content provides you with first insights into the containerized cloud IAM from Univention, derived from the UCS appliance.

# Container UCS Base

This project does build a few container images which are prepared so that UCS
packages can be installed.

It started based from a fragment which we saw being repeated over and over
across many of our `Dockerfile` files.

The images are tagged according to the following pattern:

* `ucs-base-{500,501,502,503,504,505,506,510,520}`
> * 50X based on `updates.software-univention.de`
> * 5X0 based on `updates-test.software-univention.de`
* `ucs-base-dev-{500,501,502,503,504,505,506,510,520}`
> * 50X based on `updates.knut.univention.de`
> * 5X0 based on `updates-test.software-univention.de`

All with `latest` and semantic-release `v0.10.0`.


## Errata release handling

Be aware that the base containers do include the errata releases as well by
default. This means that your images will potentially change if they are built
again in the future.

To mitigate this we do additionally tag the `50X` images with a date based
suffix based on the build date and keep the packages included in the image. This
way the downstream images can rely on `apt-get install` installing precisely the
same packages again as long as there is no usage of `apt-get update`.

Example tags:

- `ucs-base-506:0.12.0-build-2024-04-18`
- `ucs-base-507:0.12.0-build-2024-04-18`


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

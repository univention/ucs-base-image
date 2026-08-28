# ucs-distroless-python

Minimal Python base images built from the UCS apt repositories with Bazel.

These images aren't a variant of `ucs-base`. The images under `docker/ucs-base`
exist so that you can install UCS packages into them. These images have no
shell, no apt, and no dpkg, so you can't install anything into them. Instead, a
derived image copies in a prebuilt virtual environment and sets an exec-form
`ENTRYPOINT`.

The images support UCS 5.3 only. A 5.2 variant needs its own manifest, because
it uses `python3.11` and the bookworm package names differ.

## Variants

| Target | Packages | Size | Choose it for |
|---|---|---|---|
| `//:ucs530` | 25 | 55 MB | A Python service whose native extensions need nothing beyond glibc, libstdc++, and the libraries that the Python standard library links. Start here |
| `//:ucs530_ldap` | 36 | 58 MB | A service that talks LDAP through `python-ldap`, or that authenticates with SASL or Kerberos |
| `//:ucs530_debug` | 26 | 57 MB | Ephemeral debug containers. Adds busybox at `/bin/sh`. Never deploy it |

For comparison, `ucs-base-python` contains 97 packages and is 252 MB. Sizes are
for the flattened root filesystem, which is what a node stores.

The following table shows the services migrated so far:

| Service | Components | Size |
|---|---|---|
| `events-and-consumer-api` | 153 to 82 | 333 MB to 136 MB |
| `dispatcher` | 114 to 43 | 267 MB to 70 MB |
| `prefill` | 131 to 60 | 283 MB to 86 MB |
| `directory-importer` | 141 to 81 | 336 MB to 142 MB |

## Use an image in a service

### What the base image provides

The base image runs as UID 1000, user `app`, with the home directory `/app`.
It sets the `SSL_CERT_FILE`, `LANG`, and `PYTHONUNBUFFERED` environment
variables. Both `/usr/bin/python` and `/usr/bin/python3` are symlinks to
`python3.13`.

### Set an entrypoint

The base image doesn't set `ENTRYPOINT` or `CMD`. In your derived image, set an
exec-form `ENTRYPOINT` that points to a binary:

```dockerfile
FROM ${UCS_DISTROLESS_IMAGE}:${UCS_DISTROLESS_IMAGE_TAG} AS final
COPY --from=build /app/myservice /app/myservice
ENTRYPOINT [ "/app/myservice/.venv/bin/myservice" ]
```

If your service sets only `CMD`, the container doesn't start. The
`/entrypoint.d/` mechanism that `ucs-base` provides isn't available either.

### Handle signals as PID 1

`ucs-base` runs `tini` as PID 1. This image doesn't, so the binary in your
`ENTRYPOINT` runs as PID 1 itself.

*   PID 1 gets no default signal handlers. A service that doesn't install a
    SIGTERM handler ignores the signal, so Kubernetes waits out
    `terminationGracePeriodSeconds` and then sends SIGKILL. Most Python servers,
    including uvicorn, install one already.
*   PID 1 inherits orphaned processes. A service that spawns subprocesses has to
    reap them.

Fix a signal or zombie problem in the service rather than adding an init shim to
the image.

### Work without a shell

Because the image contains no shell, the following don't work:

*   `exec` probes that run `sh -c`. Call the interpreter in your virtual
    environment by absolute path instead, or use an `httpGet` or `tcpSocket`
    probe. Those probe types are unaffected.
*   `kubectl exec <pod> -- sh`. To open a shell, see
    [Debug a running pod](#debug-a-running-pod).
*   `RUN` steps in the final build stage.

### Check a service before you migrate it

Run the following checks against your virtual environment. Each of these
problems appears at runtime, not at build time.

1.  **Search for `find_library`.** In this image,
    `ctypes.util.find_library()` returns `None`, because CPython calls
    `/sbin/ldconfig -p` to resolve the name. Supporting the call costs
    `libc-bin` and about 10 executables, so the image omits it. Outside of the
    build machinery in setuptools, few packages call it.

    ```bash
    grep -r find_library /path/to/.venv
    ```

1.  **Load every shared object with `ctypes.CDLL`.** Importing a module isn't
    enough. A package can fall back to a pure-Python implementation when a
    shared library is missing, and the import still succeeds. For example,
    without `libstdc++6`, `import frozenlist` succeeds but runs the slower
    implementation.

1.  **Load the SASL plugin explicitly, if your service uses SASL.** SASL
    mechanisms are loaded with `dlopen` when the service binds, not when it
    imports. A successful call to `ldap.sasl.gssapi()` doesn't prove that
    `libsasl2-modules-gssapi-mit` is present.

If your service needs a shared library that none of the variants provide, add it
to a manifest. For more information, see
[Update the package list](#update-the-package-list).

### Debug a running pod

To get a shell next to a running container, start an ephemeral container that
uses the debug variant:

```bash
kubectl debug -it POD_NAME \
  --image=REGISTRY/ucs-distroless-python-debug-530 \
  --target=CONTAINER_NAME
```

The debug variant is the base image plus `busybox-static` at `/bin/sh`.

**Caution:** Don't deploy the debug variant. It contains 65 known
vulnerabilities, compared to 51 in the image that it debugs.

## Develop the images

### Repository layout

| File | Description |
|---|---|
| `ucs530-curated.yaml` | The package list. Start here |
| `ucs530-ldap.yaml` | The base closure, plus the native dependencies of `python-ldap` and krb5 |
| `ucs530-debug.yaml` | The base closure, plus busybox |
| `certs.yaml` | `ca-certificates`, used for the certificate bundle only |
| `ucs530-probe.yaml` | A generated copy of the curated list, used by the drift check. Committed because `MODULE.bazel` reads it at load time |
| `MODULE.bazel` | Connects the manifests to the apt repositories |
| `BUILD.bazel`, `base.bzl` | Assemble an image |
| `tools/check-drift.sh` | Checks that the closures are complete |

Each rule in `base.bzl` produces a tar file, and `oci_image` combines the tar
files into layers. Where a Dockerfile writes `RUN … > /etc/something`, this
build uses a rule instead.

### Build an image

```bash
bazel build //:ucs530_tarball --output_groups=+tarball
podman load -i bazel-bin/ucs530_tarball/tarball.tar
trivy image --image-src podman --scanners vuln localhost/ucs-distroless-python:ucs530
```

You must pass `--output_groups=+tarball`. By default, `oci_load` produces an
mtree specification and a runner script rather than the tar file.

Scan the image after `podman load` rather than with `trivy --input`. The tar
file mixes compressed and uncompressed layers but declares all of them as
`.tar.gz`, which the `--input` path of Trivy rejects.

### Update the package list

Each manifest sets `resolve_transitive = False`, so Bazel installs exactly the
packages that the manifest lists. When you add a package, add its dependencies
too.

To verify a closure, run `tools/check-drift.sh`. The script resolves the same
list with transitive resolution enabled and fails if the resolver needs a
package that the manifest omits. The script also lists the deliberate
exclusions, with a reason for each. Read those reasons before you add an
excluded package back.

CI runs the drift check on every change under `distroless/` and on a
schedule.

The manifests have no lock files. A manifest sets which packages an image
contains, and the mirror sets which versions, so a rebuild picks up errata
without a relock step.

### Known issues

Each of the following problems produces an incorrect SBOM instead of an error.

*   **You can't remove `base-files`.** It provides `/etc/debian_version`, which
    Trivy uses to detect Debian. Without the file, Trivy reports `family=none`
    and lists no operating system packages. Trivy doesn't read `os-release`.
*   **Two `dpkg_status` layers overwrite each other.** Both write to
    `/var/lib/dpkg/status`, and the later layer wins. For a package outside the
    main closure, use `dpkg_statusd`, which writes
    `/var/lib/dpkg/status.d/PACKAGE_NAME` and combines with other layers.
*   **A broken symlink produces no error.** The `mtree` attribute of `tar`
    accepts a target that no layer provides.
*   **A lock file label must start with `@@//`.** For example, use
    `@@//:x.lock.json`. The label `//:x.lock.json` resolves to nothing and
    produces an empty image. Stale package indexes also survive `bazel clean`,
    so a relock doesn't reliably pick up new versions. To clear the indexes,
    run `bazel clean --expunge`.

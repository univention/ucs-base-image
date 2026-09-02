# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2026 Univention GmbH

"""
Check that the base image can run a Python program.

Every import here corresponds to a package the manifests carry for it, so a
dropped package fails this test instead of a service at runtime.
"""

from __future__ import annotations

import ctypes
import os
import pathlib
import subprocess
import sys


# module -> the package in the manifest that provides its shared library
STDLIB = {
    "bz2": "libbz2-1.0",
    "ctypes": "libffi8",
    "curses": "libncursesw6",
    "dbm.ndbm": "libdb5.3t64",
    "hashlib": "libssl3t64",
    "lzma": "liblzma5",
    "readline": "libreadline8t64",
    "sqlite3": "libsqlite3-0",
    "ssl": "libssl3t64",
    "uuid": "libuuid1",
    "xml.etree.ElementTree": "libexpat1",
    "zlib": "zlib1g",
    "zoneinfo": "tzdata",
}


def check_import(module: str, package: str) -> str | None:
    """Return a failure message, or None when the module imports."""
    try:
        __import__(module)
    except Exception as error:  # noqa: BLE001 - any failure is a failure
        return f"import {module} failed ({package}): {error}"
    return None


failures = [
    message
    for module, package in STDLIB.items()
    if (message := check_import(module, package))
]

# tzdata and netbase ship data files, not libraries, so importing proves nothing
try:
    import zoneinfo

    zoneinfo.ZoneInfo("Europe/Berlin")
except Exception as error:
    failures.append(f"zoneinfo lookup failed (tzdata): {error}")

if not pathlib.Path("/etc/services").is_file():
    failures.append("/etc/services is missing (netbase)")

if not pathlib.Path("/etc/mime.types").is_file():
    failures.append("/etc/mime.types is missing (media-types)")

# Neither of the next two is a dependency of anything in the closure, so
# tools/check-drift.sh cannot notice their removal.

# trivy reads this to detect the distro; without it the SBOM lists no OS packages
if not pathlib.Path("/etc/debian_version").is_file():
    failures.append("/etc/debian_version is missing (base-files)")

# wheels with C++ extensions link this and fall back to pure Python without it
try:
    ctypes.CDLL("libstdc++.so.6")
except OSError as error:
    failures.append(f"libstdc++.so.6 does not load (libstdc++6): {error}")

bundle = os.environ.get("SSL_CERT_FILE", "")
if not bundle or not pathlib.Path(bundle).is_file():
    failures.append(f"SSL_CERT_FILE does not point at a readable bundle: {bundle!r}")

if os.getuid() != 1000:
    failures.append(f"expected uid 1000, got {os.getuid()}")

# The shell variant links every busybox applet into /bin. busybox resolves them
# itself under its own shell, but an exec straight into the container does not.
busybox = pathlib.Path("/bin/busybox")
if busybox.is_file():
    listed = subprocess.run(
        [str(busybox), "--list"],  # noqa: S603 - literal argv, no shell
        capture_output=True,
        text=True,
        check=False,
    ).stdout.split()
    missing = [a for a in listed if not pathlib.Path(f"/bin/{a}").exists()]
    if missing:
        failures.append(
            f"{len(missing)} busybox applets have no symlink in /bin: "
            f"{', '.join(sorted(missing)[:5])}...",
        )

if failures:
    for failure in failures:
        print(f"FAIL: {failure}", file=sys.stderr)
    raise SystemExit(1)

print(
    f"ok: python {sys.version.split()[0]}, {len(STDLIB)} stdlib modules, uid {os.getuid()}",
)

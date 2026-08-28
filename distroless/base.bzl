# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2026 Univention GmbH

"""Minimal Python base image for Nubus services.

Each rule produces a tar and oci_image unions them into layers.
"""

load("@rules_distroless//apt:defs.bzl", "dpkg_statusd")
load("@rules_distroless//distroless:defs.bzl", "cacerts", "group", "os_release", "passwd")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load")
load("@tar.bzl", "tar")

# uid, gid and name follow decision-records nubus/deployment/0007.
UID = 1000
GID = 1000
USERNAME = "app"

def ucs_base(name, repo, python, debian_version, debian_codename, debug = False):
    """A minimal Python base image.

    Args:
        name: target name, for example "ucs530"
        repo: apt repo to take the package closure from, for example "ucs530"
        python: interpreter binary name, for example "python3.13"
        debian_version: Debian major version, for example "13"
        debian_codename: for example "trixie"
        debug: add /bin/sh pointing at busybox. Requires a repo whose closure
            contains busybox-static. Never for a shipped image.
    """

    passwd(
        name = name + "_passwd",
        entries = [
            {"uid": 0, "gid": 0, "home": "/root", "shell": "/sbin/nologin", "username": "root"},
            {"uid": UID, "gid": GID, "home": "/app", "shell": "/sbin/nologin", "username": USERNAME},
        ],
    )

    group(
        name = name + "_group",
        entries = [
            {"name": "root", "gid": 0},
            {"name": USERNAME, "gid": GID},
        ],
    )

    # os-release is shell syntax: values with spaces must stay quoted.
    os_release(
        name = name + "_os_release",
        content = {
            "PRETTY_NAME": '"Univention Nubus base"',
            "NAME": '"Debian GNU/Linux"',
            "ID": "debian",
            "VERSION_ID": '"%s"' % debian_version,
            "VERSION": '"%s (%s)"' % (debian_version, debian_codename),
            "HOME_URL": '"https://www.univention.de/"',
        },
    )

    # Some services invoke `python` directly. base-files would normally provide
    # the /etc/os-release symlink.
    tar(
        name = name + "_links",
        mtree = [
            "./usr/bin/python type=link link=/usr/bin/" + python,
            "./usr/bin/python3 type=link link=/usr/bin/" + python,
            "./etc/os-release type=link link=/usr/lib/os-release",
        ],
    )

    cacerts(
        name = name + "_cacerts",
        package = "@certs//ca-certificates:data",
    )

    # @repo//:dpkg_status covers only its own repo, so ca-certificates would be
    # missing from the SBOM. dpkg_statusd composes; dpkg_status would overwrite.
    dpkg_statusd(
        name = name + "_certs_status",
        control = "@certs//ca-certificates:control",
        package_name = "ca-certificates",
    )

    if debug:
        tar(
            name = name + "_debug_links",
            mtree = [
                "./bin/sh type=link link=/usr/bin/busybox",
                "./bin/busybox type=link link=/usr/bin/busybox",
            ],
        )

    oci_image(
        name = name,
        architecture = "amd64",
        os = "linux",
        user = str(UID),
        env = {
            "SSL_CERT_FILE": "/etc/ssl/certs/ca-certificates.crt",
            "LANG": "C.UTF-8",
            "PYTHONUNBUFFERED": "1",
        },
        tars = [
            "@%s//:flat" % repo,
            "@%s//:dpkg_status" % repo,
            ":" + name + "_cacerts",
            ":" + name + "_certs_status",
            ":" + name + "_passwd",
            ":" + name + "_group",
            ":" + name + "_os_release",
            ":" + name + "_links",
        ] + ([":" + name + "_debug_links"] if debug else []),
    )

    oci_load(
        name = name + "_tarball",
        image = ":" + name,
        repo_tags = ["ucs-distroless-python:" + name],
    )

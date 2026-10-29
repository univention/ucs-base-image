#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2026 Univention GmbH

# Resolves a curated package list with transitive resolution ON and compares
# the result against the manifest. Needs network.
#
# Usage: tools/check-drift.sh [python|nginx]
set -euo pipefail
cd "$(dirname "$0")/.."

# Listed on purpose, depended on by nothing.
DELIBERATE_ORPHANS=(
    base-files  # /etc/debian_version
)

# The resolver wants these and we deliberately do not ship them.
case "${1:-python}" in
    python)
        CURATED=ucs530-curated.yaml
        PROBE=ucs530-probe.yaml
        PROBE_REPO=ucs530_probe
        DELIBERATE_EXCLUSIONS=(
            debconf                  # via tzdata; cannot run (no perl, no shell)
            readline-common          # /etc/inputrc, for an interactive REPL
            openssl-provider-legacy  # legacy crypto providers, unused
            mawk                     # arrives with base-files; nothing calls awk
        )
        ;;
    nginx)
        CURATED=ucs530-nginx.yaml
        PROBE=ucs530-nginx-probe.yaml
        PROBE_REPO=ucs530_nginx_probe
        DELIBERATE_EXCLUSIONS=(
            debconf                  # via nginx-common; cannot run (no perl, no shell)
            openssl-provider-legacy  # legacy crypto providers, unused
            mawk                     # arrives with base-files; nothing calls awk
            iproute2                 # a dependency of the nginx package; the daemon never runs it
            libbpf1 libcap2 libcap2-bin libcom-err2 libdb5.3t64 libelf1t64     # via iproute2
            libgssapi-krb5-2 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0  # via iproute2
            libmnl0 libselinux1 libtirpc-common libtirpc3t64 libxtables12      # via iproute2
        )
        ;;
    *)
        echo "usage: $0 [python|nginx]" >&2
        exit 2
        ;;
esac
PROBE_LOCK="${PROBE%.yaml}.lock.json"

# Regenerated every run so the probe cannot diverge from the curated list.
{
    sed -n '1,2p' "$CURATED"
    echo
    echo "# GENERATED from ${CURATED} by tools/check-drift.sh. Do not edit."
    sed -n '3,$p' "$CURATED"
} > "$PROBE"

echo "resolving ${CURATED} with transitive resolution on..."
bazel run "@${PROBE_REPO}//:lock" >/dev/null 2>&1

# No jq in the build image; the lockfile has one "name" key per package.
pkgs_from_manifest() { sed -n '/^packages:/,$p' "$1" | sed -n 's/^[[:space:]]*- "\([^"]*\)".*/\1/p'; }
pkgs_from_lock()     { grep -oE '"name": *"[^"]+"' "$1" | sed 's/.*: *"//; s/"$//'; }

pkgs_from_manifest "$CURATED"  | sort -u > /tmp/drift-curated.txt
pkgs_from_lock     "$PROBE_LOCK" | sort -u > /tmp/drift-resolved.txt

printf '%s\n' "${DELIBERATE_EXCLUSIONS[@]}" | sort -u > /tmp/drift-excluded.txt
missing=$(comm -13 /tmp/drift-curated.txt /tmp/drift-resolved.txt \
          | comm -23 - /tmp/drift-excluded.txt)
unused=$(comm -23 /tmp/drift-curated.txt /tmp/drift-resolved.txt \
         | grep -vxF "$(printf '%s\n' "${DELIBERATE_ORPHANS[@]}")" || true)

printf '\ncurated: %s packages   resolved: %s packages\n\n' \
    "$(wc -l < /tmp/drift-curated.txt)" "$(wc -l < /tmp/drift-resolved.txt)"

if [ -n "$unused" ]; then
    echo "UNUSED: listed but nothing depends on them"
    printf '  %s\n' $unused
    echo
fi

if [ -n "$missing" ]; then
    echo "MISSING: the resolver needs these and they are not listed"
    printf '  %s\n' $missing
    echo
    echo "The curated closure is stale. Add them to ${CURATED}, or work out"
    echo "which listed package gained the dependency and decide deliberately."
    exit 1
fi

echo "OK: curated closure covers everything the resolver needs."

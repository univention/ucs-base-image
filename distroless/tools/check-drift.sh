#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2026 Univention GmbH

# Resolves the curated package list with transitive resolution ON and compares
# the result against the manifest. Needs network.
set -euo pipefail
cd "$(dirname "$0")/.."

CURATED=ucs530-curated.yaml
PROBE=ucs530-probe.yaml
PROBE_LOCK=ucs530-probe.lock.json

# Listed on purpose, depended on by nothing.
DELIBERATE_ORPHANS=(
    base-files  # /etc/debian_version
)

# The resolver wants these and we deliberately do not ship them.
DELIBERATE_EXCLUSIONS=(
    debconf                  # via tzdata; cannot run (no perl, no shell)
    readline-common          # /etc/inputrc, for an interactive REPL
    openssl-provider-legacy  # legacy crypto providers, unused
    mawk                     # arrives with base-files; nothing calls awk
)

# Regenerated every run so the probe cannot diverge from the curated list.
{
    sed -n '1,2p' "$CURATED"
    echo
    echo "# GENERATED from ${CURATED} by tools/check-drift.sh. Do not edit."
    sed -n '3,$p' "$CURATED"
} > "$PROBE"

echo "resolving ${CURATED} with transitive resolution on..."
bazel run @ucs530_probe//:lock >/dev/null 2>&1

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

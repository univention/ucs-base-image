#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2026 Univention GmbH
#
# Queries the Univention errata API and writes ERRATA_LEVEL_<version>=<level>
# entries to errata.env for each UCS version passed as arguments.
#
# Usage: find-latest-errata.sh <ucs_version> [<ucs_version> ...]
# Example: find-latest-errata.sh 524 525
#
# Each <ucs_version> is a compact integer like 524 (→ 5.2-4) or 5010 (→ 5.0-10).
# The errata JSON URL is derived from the major.minor of the first version argument.

set -eu

ERRATA_BASE_URL="https://errata.software-univention.de"
OUTPUT_FILE="${OUTPUT_FILE:-errata.env}"

# Convert a UCS_VERSION integer (e.g. 524, 5010) to the dotted release
# string used by the errata API (e.g. 5.2-4, 5.0-10).
# Format: first digit = major, second digit = minor, rest = patch.
ucs_version_to_release() {
    ver="$1"
    major="${ver%"${ver#?}"}"          # first character
    rest="${ver#?}"                     # everything after first char
    minor="${rest%"${rest#?}"}"        # second character (first of rest)
    patch="${rest#?}"                   # everything after second char
    echo "${major}.${minor}-${patch}"
}

# Extract major.minor from a version integer (e.g. 524 → 5.2).
ucs_version_to_major_minor() {
    ver="$1"
    major="${ver%"${ver#?}"}"
    rest="${ver#?}"
    minor="${rest%"${rest#?}"}"
    echo "${major}.${minor}"
}

fetch_errata_level() {
    ucs_release="$1"
    errata_json_url="$2"

    errata_json=$(mktemp)
    http_status=$(curl --silent --show-error --retry 3 --retry-delay 5 \
        --retry-connrefused --max-time 30 --connect-timeout 10 \
        --compressed --output "${errata_json}" --write-out '%{http_code}' \
        "${errata_json_url}") || true

    if [ "${http_status}" = "404" ]; then
        echo "No errata published yet for ${ucs_release} (${errata_json_url} returned 404); defaulting to 0" >&2
        rm -f "${errata_json}"
        echo "0"
        return 0
    fi

    if [ "${http_status}" != "200" ]; then
        echo "ERROR: Unexpected HTTP status ${http_status} fetching ${errata_json_url}" >&2
        rm -f "${errata_json}"
        exit 1
    fi

    level=$(python3 "$(dirname "$0")/parse-errata-level.py" "${ucs_release}" < "${errata_json}")
    rm -f "${errata_json}"

    if [ "${level}" = "null" ] || [ -z "${level}" ]; then
        echo "ERROR: Could not determine errata level for ${ucs_release}" >&2
        exit 1
    fi

    echo "${level}"
}

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <ucs_version> [<ucs_version> ...]" >&2
    exit 1
fi

for ver in "$@"; do
    major_minor=$(ucs_version_to_major_minor "${ver}")
    errata_json_url="${ERRATA_BASE_URL}/errata-${major_minor}.json"
    echo "Fetching errata data from ${errata_json_url}" >&2
    release=$(ucs_version_to_release "${ver}")
    level=$(fetch_errata_level "${release}" "${errata_json_url}")
    echo "ERRATA_LEVEL_${ver}=${level}" >> "${OUTPUT_FILE}"
done

cat "${OUTPUT_FILE}"

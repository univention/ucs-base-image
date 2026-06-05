#!/usr/bin/env python3
# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightText: 2026 Univention GmbH
#
# Reads errata JSON from stdin and prints the highest advisory number
# for the release passed as the first argument. If no advisories exist yet
# for the release, prints 0.
#
# Usage: curl ... | python3 parse-errata-level.py <ucs_release>
# Example: curl ... | python3 parse-errata-level.py 5.2-5

import json
import sys


if len(sys.argv) != 2:
    print("Usage: parse-errata-level.py <ucs_release>", file=sys.stderr)
    sys.exit(1)

ucs_release = sys.argv[1]

# The errata JSON may contain non-UTF-8 bytes; latin-1 avoids decode errors.
# The JSON also contains \\0 sequences (escaped backslash + digit) that
# python >= 3.13 rejects as invalid JSON escapes. We double-escape them first.
raw = sys.stdin.buffer.read().decode("latin-1")
raw = raw.replace("\\\\0", "\\\\\\\\0")

data = json.loads(raw)
numbers = [
    e["number"]
    for e in data
    if ucs_release in e.get("releases", []) and e.get("support") == "core"
]

if not numbers:
    # No errata published yet for this release; the errata level is 0.
    print(
        f"No advisories found for release {ucs_release}; defaulting to 0",
        file=sys.stderr,
    )
    print(0)
    sys.exit(0)

print(max(numbers))

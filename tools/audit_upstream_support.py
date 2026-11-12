#!/usr/bin/env python3
"""Read-only inspection of Dopamine 3.x momentarius support metadata.

This tool does not run exploits, modify devices or claim jailbreak readiness.
"""
from __future__ import annotations

import argparse
import json
import plistlib
import re
from pathlib import Path
from urllib.request import Request, urlopen

OFFICIAL_URL = (
    "https://raw.githubusercontent.com/opa334/Dopamine/3.x/"
    "Application/Dopamine/Exploits/momentarius/Info.plist"
)
TARGET = {"device": "iPhone12,8", "chip": "A13", "version": "26.1", "build": "23B85"}
VERSION_RE = re.compile(r"^\d+(?:\.\d+){0,3}$")


def version_parts(raw: str) -> tuple[int, ...]:
    if not isinstance(raw, str) or not VERSION_RE.fullmatch(raw):
        raise ValueError(f"Invalid version: {raw!r}")
    parts = tuple(int(part) for part in raw.split("."))
    return parts + (0,) * (4 - len(parts))


def in_range(version: str, low: str, high: str) -> bool:
    value = version_parts(version)
    return version_parts(low) <= value <= version_parts(high)


def inspect_plist(data: bytes, *, chip: str = "A13",
                  version: str = "26.1", build: str = "23B85") -> dict:
    """Check declared metadata only; listed != exploitable or jailbreakable."""
    parsed = plistlib.loads(data)
    flavors = parsed.get("DPExploitFlavors", {})
    if not isinstance(flavors, dict) or not flavors:
        raise ValueError("Missing DPExploitFlavors metadata")
    matching_flavors = []
    for name, flavor in flavors.items():
        if chip not in flavor.get("DPSupportedDevices", []):
            continue
        listed_build = any(
            build in item.get("Builds", [])
            for item in flavor.get("DPSupportInclude", [])
            if isinstance(item, dict)
        )
        listed_version = any(
            in_range(version, item["Start"], item["End"])
            for item in flavor.get("DPSupportedRanges", [])
            if isinstance(item, dict)
            and isinstance(item.get("Start"), str)
            and isinstance(item.get("End"), str)
        )
        if listed_build or listed_version:
            matching_flavors.append(str(name))
    return {
        "targetDevice": TARGET["device"],
        "chip": chip,
        "iosVersion": version,
        "build": build,
        "momentariusListedInMetadata": bool(matching_flavors),
        "matchingFlavors": matching_flavors,
        "jailbreakValidated": False,
        "note": (
            "This result covers only momentarius support declarations. "
            "A listed version alone cannot prove a working jailbreak."
        ),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--plist-file", type=Path,
                        help="Offline local snapshot of the official Info.plist")
    source.add_argument("--fetch-official", action="store_true",
                        help="Read the Dopamine 3.x Info.plist over HTTPS")
    args = parser.parse_args()
    if args.fetch_official:
        request = Request(OFFICIAL_URL, headers={"User-Agent": "DopaSE-metadata-audit/1.0"})
        with urlopen(request, timeout=20) as response:
            data = response.read(100_000)
    else:
        data = args.plist_file.read_bytes()
    print(json.dumps(inspect_plist(data), indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

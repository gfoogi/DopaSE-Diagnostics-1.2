#!/usr/bin/env python3
"""Read, but never modify, official fork's momentarius compatibility declaration."""
import argparse
import json
import plistlib
from pathlib import Path

RELATIVE = Path('Application/Dopamine/Exploits/momentarius/Info.plist')

def inspect(root: Path, build: str):
    source = root / RELATIVE
    if not source.is_file():
        raise FileNotFoundError(f'Missing file: {source}. Specify the root of a Dopamine 3.x checkout.')
    info = plistlib.loads(source.read_bytes())
    flavors = info.get('DPExploitFlavors', {})
    records = []
    for name, data in flavors.items():
        included = []
        for group in data.get('DPSupportInclude', []):
            included.extend(group.get('Builds', []))
        records.append({
            'flavor': name,
            'devices': data.get('DPSupportedDevices', []),
            'explicitBuilds': included,
            'ranges': data.get('DPSupportedRanges', []),
            'buildExplicitlyListed': build in included,
        })
    return {'path': str(source), 'requestedBuild': build, 'flavors': records,
            'warning': 'Metadata alone never proves an exploit is safe or effective. No changes were made.'}

def main():
    parser = argparse.ArgumentParser(description='Read official Dopamine exploit support metadata without changing it')
    parser.add_argument('repository', type=Path)
    parser.add_argument('--build', default='23B85')
    args = parser.parse_args()
    print(json.dumps(inspect(args.repository, args.build), ensure_ascii=False, indent=2))

if __name__ == '__main__':
    main()

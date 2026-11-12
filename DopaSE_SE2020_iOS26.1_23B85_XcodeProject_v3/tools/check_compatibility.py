#!/usr/bin/env python3
"""Pure-Python mirror of the app's read-only support matrix for repeatable tests."""
import argparse
import json
from pathlib import Path

DEFAULT_MANIFEST = Path(__file__).resolve().parents[1] / 'DopaSEDiagnostics' / 'Resources' / 'compatibility.json'

def parse_version(value):
    chunks = value.split('.')
    if not 1 <= len(chunks) <= 4 or any(not x or not x.isascii() or not x.isdecimal() for x in chunks):
        return None
    parts = tuple(int(x) for x in chunks)
    return parts + (0,) * (max(3, len(parts)) - len(parts))

def evaluate(model, ios, build, manifest, simulator=False):
    if simulator or model != manifest['targetMachine']:
        return {'status': 'otherDevice', 'reason': 'Device is not a physical iPhone SE 2020'}
    if build in manifest['explicitlyUnsupportedBuilds']:
        return {'status': 'unsupported', 'reason': 'Official Dopamine metadata excludes this build'}
    if build in manifest['explicitlySupportedBuilds']:
        if ios != '26.1':
            return {'status': 'unknown', 'reason': 'Build and iOS version do not match'}
        return {'status': 'supported', 'reason': 'Explicitly listed beta build'}
    version = parse_version(ios)
    if version is not None:
        for item in manifest['supportedVersionRanges']:
            start, end = parse_version(item['min']), parse_version(item['max'])
            if start <= version <= end:
                return {'status': 'supported', 'reason': 'Published supported version range'}
    return {'status': 'unknown', 'reason': 'No verified support in the manifest'}

def main():
    parser = argparse.ArgumentParser(description='Check published Dopamine compatibility metadata (no jailbreak)')
    parser.add_argument('--model', default='iPhone12,8')
    parser.add_argument('--ios', default='26.1')
    parser.add_argument('--build', default='23B85')
    parser.add_argument('--manifest', type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument('--simulator', action='store_true')
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text(encoding='utf-8'))
    report = evaluate(args.model, args.ios, args.build, manifest, args.simulator)
    report.update({'model': args.model, 'ios': args.ios, 'build': args.build, 'manifestDate': manifest['researchDate']})
    print(json.dumps(report, ensure_ascii=False, indent=2))

if __name__ == '__main__':
    main()

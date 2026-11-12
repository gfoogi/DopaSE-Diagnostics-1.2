"""Offline, non-exploit tests for Dopamine metadata inspection."""
import json
import plistlib
import unittest
from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "audit_upstream_support", ROOT / "tools" / "audit_upstream_support.py"
)
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)


def fixture():
    return plistlib.dumps({
        "DPExploitFlavors": {
            "default": {
                "DPSupportedDevices": ["A12", "A13"],
                "DPSupportInclude": [
                    {"Builds": ["23B5044l", "23B5059e", "23B5064e"]}
                ],
                "DPSupportedRanges": [{"Start": "15.0", "End": "26.0.1"}],
            }
        },
        "DPExploitType": "PPL",
    })


class UpstreamSupportAuditTests(unittest.TestCase):
    def test_exact_final_build_is_not_listed(self):
        self.assertFalse(AUDIT.inspect_plist(fixture())["momentariusListedInMetadata"])

    def test_specific_26_1_beta_is_listed(self):
        out = AUDIT.inspect_plist(
            fixture(), version="26.1", build="23B5064e"
        )
        self.assertTrue(out["momentariusListedInMetadata"])
        self.assertFalse(out["jailbreakValidated"])

    def test_version_range_works(self):
        out = AUDIT.inspect_plist(
            fixture(), version="26.0.1", build="23A355"
        )
        self.assertTrue(out["momentariusListedInMetadata"])

    def test_wrong_chip_not_listed(self):
        self.assertFalse(
            AUDIT.inspect_plist(fixture(), chip="A14")["momentariusListedInMetadata"]
        )

    def test_later_version_not_in_range(self):
        self.assertFalse(
            AUDIT.inspect_plist(
                fixture(), version="26.2", build="23C55"
            )["momentariusListedInMetadata"]
        )

    def test_normalized_versions(self):
        self.assertTrue(AUDIT.in_range("26", "15.0", "26.0.1"))
        self.assertFalse(AUDIT.in_range("26.0.2", "15.0", "26.0.1"))

    def test_invalid_version_is_rejected(self):
        with self.assertRaises(ValueError):
            AUDIT.version_parts("26.0.1beta")

    def test_empty_manifest_is_rejected(self):
        with self.assertRaises(ValueError):
            AUDIT.inspect_plist(plistlib.dumps({"DPExploitFlavors": {}}))

    def test_research_gate_remains_closed(self):
        manifest = json.loads(
            (ROOT / "research" / "23B85" / "manifest.json")
            .read_text(encoding="utf-8")
        )
        self.assertFalse(manifest["release"]["jailbreakReady"])
        self.assertFalse(manifest["release"]["deviceExecutionEnabled"])


if __name__ == "__main__":
    unittest.main()

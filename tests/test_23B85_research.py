"""Fail-closed tests for the public 23B85 research manifest.

These tests DO NOT exercise vulnerabilities or run device code.
"""
from pathlib import Path
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "research" / "23B85" / "manifest.json"


class ResearchGateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.m = json.loads(MANIFEST.read_text(encoding="utf-8"))

    def test_exact_target(self):
        self.assertEqual(self.m["target"], {"machine": "iPhone12,8", "chip": "A13", "ios": "26.1", "build": "23B85"})

    def test_upstream_does_not_claim_support(self):
        self.assertFalse(self.m["upstream"]["supported"])
        self.assertNotIn("23B85", self.m["upstream"]["supportedBetas"])

    def test_candidate_is_not_verified_on_se2020(self):
        self.assertTrue(self.m["research"]["candidateExists"])
        self.assertFalse(self.m["research"]["validatedOnTarget"])
        self.assertFalse(self.m["research"]["kernelPrimitiveValidated"])
        self.assertFalse(self.m["research"]["bootstrapValidated"])

    def test_exploit_execution_gate_is_closed(self):
        self.assertFalse(self.m["release"]["jailbreakReady"])
        self.assertFalse(self.m["release"]["deviceExecutionEnabled"])
        self.assertFalse(self.m["release"]["releaseAllowed"])

    def test_source_refs_are_public_and_reviewable(self):
        self.assertTrue(all(url.startswith("https://") for url in self.m["references"]))


if __name__ == "__main__":
    unittest.main()

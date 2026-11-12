import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from check_compatibility import evaluate, parse_version  # noqa: E402

class MatrixTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads((ROOT / 'DopaSEDiagnostics/Resources/compatibility.json').read_text(encoding='utf-8'))

    def check(self, model, ios, build, status, simulator=False):
        self.assertEqual(evaluate(model, ios, build, self.manifest, simulator)['status'], status)

    def test_target_final_26_1_denied(self):
        self.check('iPhone12,8', '26.1', '23B85', 'unsupported')

    def test_each_exception_beta(self):
        for build in self.manifest['explicitlySupportedBuilds']:
            with self.subTest(build=build):
                self.check('iPhone12,8', '26.1', build, 'supported')

    def test_supported_ranges(self):
        self.check('iPhone12,8', '26.0.1', '23A355', 'supported')
        self.check('iPhone12,8', '18.7.1', '22H31', 'supported')

    def test_outside_ranges(self):
        self.check('iPhone12,8', '26.2', '23C1', 'unknown')
        self.check('iPhone12,8', '18.7.2', '22H999', 'unknown')

    def test_other_device_and_simulator(self):
        self.check('iPhone13,2', '26.1', '23B85', 'otherDevice')
        self.check('iPhone12,8', '26.1', '23B85', 'otherDevice', simulator=True)

    def test_strict_version_parser(self):
        self.assertIsNone(parse_version('26.1beta'))
        self.assertEqual(parse_version('26.0.1'), (26,0,1))
        self.assertEqual(parse_version('26'), (26,0,0))

    def test_target_build_denied_even_with_mismatched_version(self):
        self.check('iPhone12,8', '26.0', '23B85', 'unsupported')

    def test_beta_build_must_match_ios_version(self):
        self.check('iPhone12,8', '26.0', '23B5044l', 'unknown')

    def test_manifest_source_integrity(self):
        self.assertEqual(self.manifest['targetMachine'], 'iPhone12,8')
        self.assertEqual(self.manifest['targetChip'], 'A13 Bionic')
        self.assertTrue(all(u.startswith('https://') for u in self.manifest['sources']))
        self.assertFalse(set(self.manifest['explicitlySupportedBuilds']) & set(self.manifest['explicitlyUnsupportedBuilds']))

    def test_manifest_no_claim_of_target_support(self):
        self.assertNotIn('23B85', self.manifest['explicitlySupportedBuilds'])
        self.assertIn('23B85', self.manifest['explicitlyUnsupportedBuilds'])

if __name__ == '__main__':
    unittest.main()

"""Static project consistency checks that also run on Windows/Linux."""
import re
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
XCODE = ROOT / 'DopaSEDiagnostics/DopaSEDiagnostics.xcodeproj'

class ProjectChecks(unittest.TestCase):
    def test_native_xcode_project_committed(self):
        self.assertTrue((XCODE/'project.pbxproj').is_file())
        self.assertTrue((XCODE/'xcshareddata/xcschemes/DopaSEDiagnostics.xcscheme').is_file())

    def test_pbx_ids_and_files(self):
        txt=(XCODE/'project.pbxproj').read_text(encoding='utf-8')
        defined=set(re.findall(r'\b([A-F0-9]{24})\s+/\*.*?\*/\s*=\s*\{',txt))
        used=set(re.findall(r'\b[A-F0-9]{24}\b',txt))
        self.assertTrue(used, 'No project identifiers found')
        self.assertFalse(used-defined, f'Undefined project references: {used-defined}')
        self.assertIn('PBXResourcesBuildPhase',txt)
        self.assertIn('compatibility.json in Resources',txt)
        for filename in ('DopaSEDiagnosticsApp.swift','ContentView.swift','DeviceProfile.swift','Compatibility.swift'):
            self.assertTrue((ROOT/'DopaSEDiagnostics/Sources'/filename).is_file())
            self.assertIn(f'{filename} in Sources',txt)

    def test_scheme_blueprint_exists(self):
        txt=(XCODE/'project.pbxproj').read_text(encoding='utf-8')
        tree=ET.parse(XCODE/'xcshareddata/xcschemes/DopaSEDiagnostics.xcscheme')
        refs=tree.findall('.//BuildableReference')
        self.assertTrue(refs)
        for ref in refs:
            self.assertEqual(ref.attrib['BuildableName'],'DopaSEDiagnostics.app')
            self.assertIn(ref.attrib['BlueprintIdentifier'],txt)

if __name__=='__main__':
    unittest.main()

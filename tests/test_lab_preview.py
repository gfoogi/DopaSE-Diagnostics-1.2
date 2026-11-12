"""Sanity checks for the unprivileged DopaSE Lab UI."""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SWIFT = ROOT / "DopaSEDiagnostics" / "Sources" / "ContentView.swift"
PROJECT = ROOT / "DopaSEDiagnostics" / "DopaSEDiagnostics.xcodeproj" / "project.pbxproj"


class LabPreviewTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = SWIFT.read_text(encoding="utf-8")
        cls.project = PROJECT.read_text(encoding="utf-8")

    def test_lab_is_distinct_from_jailbreak(self):
        self.assertIn("Не является эксплойтом или джейлбрейком", self.source)

    def test_real_device_data_and_local_memory_check(self):
        self.assertIn("DeviceProfile.current()", self.source)
        self.assertIn("Data(repeating: 0xA5, count: 4096)", self.source)

    def test_kernel_stage_is_explicitly_blocked(self):
        self.assertIn('title: "Доступ к памяти ядра"', self.source)
        self.assertIn("Настоящая эксплуатация не запускается.", self.source)

    def test_bootstrap_is_skipped(self):
        self.assertIn('title: "Установка джейлбрейка"', self.source)
        self.assertIn("Запуск bootstrap без подтверждённой цепочки не выполняется.", self.source)

    def test_no_misleading_success_report(self):
        self.assertIn("джейлбрейк НЕ выполнен.", self.source)

    def test_display_name_and_version(self):
        self.assertIn('MARKETING_VERSION = 1.3.0;', self.project)
        self.assertIn('INFOPLIST_KEY_CFBundleDisplayName = "DopaSE Lab";', self.project)


if __name__ == "__main__":
    unittest.main()

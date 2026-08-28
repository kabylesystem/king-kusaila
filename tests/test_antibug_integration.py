#!/usr/bin/env python3
import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read_jsonc(path: Path):
    raw = path.read_text(encoding="utf-8")
    return json.loads(re.sub(r"^\s*//.*$", "", raw, flags=re.MULTILINE))


def placed_modules(config):
    placed = set()
    for key, value in config.items():
        if key.startswith("group/") and isinstance(value, dict):
            placed.update(value.get("modules") or [])
        if key.startswith("modules-") and isinstance(value, list):
            placed.update(value)
    return placed


class AntibugIntegrationTest(unittest.TestCase):
    def test_antibug_is_in_every_canonical_layout(self):
        for relative in (
            "desktop/waybar/config.jsonc",
            "desktop/waybar/layouts/naly-top.jsonc",
        ):
            with self.subTest(relative=relative):
                config = read_jsonc(ROOT / relative)
                self.assertIn("custom/antibug", placed_modules(config))

    def test_restore_guard_protects_antibug(self):
        restore = (ROOT / "bin/naly-desktop-restore").read_text(encoding="utf-8")
        wanted_match = re.search(r"wanted\s*=\s*\{([^}]+)\}", restore)
        self.assertIsNotNone(wanted_match)
        self.assertIn('"custom/antibug"', wanted_match.group(1))

    def test_module_opens_diagnosis_and_process_view(self):
        modules = read_jsonc(ROOT / "desktop/waybar/modules/king.jsonc")
        antibug = modules["custom/antibug"]
        self.assertIn("naly-antibug-open", antibug["on-click"])
        self.assertIn("naly-antibug-open", antibug["on-click-right"])
        self.assertTrue((ROOT / "bin/naly-antibug-panel").is_file())
        self.assertTrue((ROOT / "bin/naly-antibug-open").is_file())

    def test_panel_is_action_first_and_has_a_real_context_menu(self):
        panel = (ROOT / "bin/naly-antibug-panel").read_text(encoding="utf-8")
        self.assertNotIn("btop", panel)
        self.assertIn("Gtk.GestureClick", panel)
        self.assertIn("set_button(3)", panel)
        self.assertIn("Calm PC now", panel)
        self.assertIn("def calm_pc_now", panel)
        for action in ("Freeze", "Resume", "Close", "Force close"):
            self.assertIn(action, panel)

    def test_hot_state_triggers_proactive_cooling(self):
        scanner = (ROOT / "bin/naly-antibug").read_text(encoding="utf-8")
        indicator = (ROOT / "bin/waybar-antibug.sh").read_text(encoding="utf-8")
        self.assertIn('PROFILE_BIN, "silencieux"', scanner)
        self.assertIn('hot_process_threshold = 20 if initial_temp >= 90 else 40', scanner)
        self.assertIn('naly-antibug-auto.service', indicator)
        self.assertIn('[ "$temp" -ge 92 ]', indicator)


if __name__ == "__main__":
    unittest.main()

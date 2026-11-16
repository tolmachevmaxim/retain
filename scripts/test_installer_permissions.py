"""Verify the permission-reset branch without running the installer or TCC."""
from pathlib import Path
import os
import subprocess
import unittest


class InstallerPermissionsTests(unittest.TestCase):
    def test_reset_requires_explicit_opt_in(self):
        source = (Path(__file__).resolve().parents[1] / "install.sh").read_text()
        start = source.index('if [ "${RETAIN_RESET_TCC:-0}" = "1" ]; then')
        end = source.index("\nfi", start) + len("\nfi")
        # Execute only this branch; replace the TCC utility with a shell function.
        branch = 'tccutil() { printf "MOCK_TCC:%s\\n" "$*"; }\n' + source[start:end]
        for value in (None, "0", "1", "true", ""):
            with self.subTest(value=value):
                env = dict(os.environ)
                env.pop("RETAIN_RESET_TCC", None)
                if value is not None:
                    env["RETAIN_RESET_TCC"] = value
                result = subprocess.run(["bash", "-c", branch], env=env,
                                        capture_output=True, text=True, check=True)
                if value == "1":
                    self.assertEqual(result.stdout.strip(),
                                     "MOCK_TCC:reset SystemPolicyAllFiles com.empatika.Retain")
                else:
                    self.assertNotIn("MOCK_TCC:", result.stdout)
                    self.assertIn("Keeping existing Full Disk Access", result.stdout)


if __name__ == "__main__":
    unittest.main()

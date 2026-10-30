"""Build the DOS version of Freepnt with Turbo Pascal 7.0 in DOSBox.

The compiler runs inside a DOSBox Staging that starts, compiles and exits on
its own, working on a temporary copy of the source so the repo stays clean.
Run from anywhere: python scripts/build.py

Environment variables:
  DOSBOX      the DOSBox Staging executable
  DOS_C_DIR   the folder mounted as the DOS C: drive
  TPC         the compiler's DOS path on that drive (default C:\\BP\\BIN\\TPC.EXE)
"""

import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PureWindowsPath

REPO_DIR = Path(__file__).resolve().parent.parent
SRC_DIR = REPO_DIR / "SRC"
UNITS_DIR = REPO_DIR / "UNITS"

DEFAULT_TPC = r"C:\BP\BIN\TPC.EXE"

# The programs, and the SHA-256 of each EXE as the current source builds it; a
# change here means the program itself changed
PROGRAMS = {
    "FREEPNT": "ddbb02fa3695893b82dce61f59d52f88f611a45c7c1f9f16b184a86f6471593e",
    "FREEPNTV": "4f05bcf7de9f97cedfd3fc422afa49b505c87c07b7a196e319243c8b6385493f",
}


def required_env(name: str, description: str) -> Path:
    value = os.environ.get(name)
    if not value:
        sys.exit(f"Set {name} to {description}")
    return Path(value)


def compile_exes(build_dir: Path) -> dict[str, bytes]:
    dosbox = required_env("DOSBOX", "the DOSBox Staging executable")
    dos_c_dir = required_env("DOS_C_DIR", "the folder mounted as the DOS C: drive")
    tpc = os.environ.get("TPC", DEFAULT_TPC)

    # The compiler's DOS path, mapped onto the host folder mounted as C:
    tpc_on_host = dos_c_dir.joinpath(*PureWindowsPath(tpc).parts[1:])
    for path in (dosbox, tpc_on_host):
        if not path.is_file():
            sys.exit(f"Not found: {path}")

    shutil.copytree(SRC_DIR, build_dir)
    shutil.copytree(UNITS_DIR, build_dir / "UNITS")
    compiles = []
    for name in PROGRAMS:
        compiles += ["-c", f"{tpc} /B /UUNITS {name}.PAS > {name}.LOG"]
    subprocess.run(
        [
            str(dosbox), "--noprimaryconf", "--nolocalconf",
            "-c", f'mount c "{dos_c_dir}"',
            "-c", f'mount d "{build_dir}"',
            "-c", "d:",
            *compiles,
            "--exit",
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    exes = {}
    for name in PROGRAMS:
        # Skip the bare FILE(line) progress lines, applying the backspaces TPC
        # erases them with; errors carry a message after them
        log = build_dir / f"{name}.LOG"
        if log.is_file():
            for line in log.read_text(encoding="cp437").splitlines():
                while "\b" in line:
                    line = re.sub("[^\b]?\b", "", line, count=1)
                line = line.strip()
                if line and not re.fullmatch(r"\S+\(\d+\)", line):
                    print(line)
        exe = build_dir / f"{name}.EXE"
        if not exe.is_file():
            sys.exit(f"Build failed: {name}.EXE was not produced")
        exes[name] = exe.read_bytes()
    return exes


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.parse_args()

    with tempfile.TemporaryDirectory() as temp:
        exes = compile_exes(Path(temp) / "build")

    for name, exe in exes.items():
        digest = hashlib.sha256(exe).hexdigest()
        if digest == PROGRAMS[name]:
            print(f"{name}.EXE unchanged ({len(exe)} bytes, SHA-256 {digest[:12]})")
        else:
            print(f"{name}.EXE changed: SHA-256 is now {digest}")
            print("If the change is intended, update PROGRAMS in build.py")


if __name__ == "__main__":
    main()

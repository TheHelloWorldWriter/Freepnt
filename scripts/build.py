"""Build the DOS version of Freepnt with Turbo Pascal 7.0 in DOSBox.

The compiler runs inside a DOSBox Staging that starts, compiles and exits on
its own, working on a temporary copy of the source so the repo stays clean.
Run from anywhere: python scripts/build.py [--web]

Environment variables:
  DOSBOX      the DOSBox Staging executable
  DOS_C_DIR   the folder mounted as the DOS C: drive
  TPC         the compiler's DOS path on that drive (default C:\\BP\\BIN\\TPC.EXE)
  BGI         the graphics driver's DOS path (default C:\\BP\\BGI\\EGAVGA.BGI)
"""

import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path, PureWindowsPath

REPO_DIR = Path(__file__).resolve().parent.parent
SRC_DIR = REPO_DIR / "SRC"
UNITS_DIR = REPO_DIR / "UNITS"
SAMPLE = REPO_DIR / "dist" / "FIREWORK.FE1"
WEB_BUNDLE = REPO_DIR / "web" / "freepnt.jsdos"

DEFAULT_TPC = r"C:\BP\BIN\TPC.EXE"
DEFAULT_BGI = r"C:\BP\BGI\EGAVGA.BGI"

# SHA-256 of the EGAVGA.BGI that comes with Borland Pascal 7.0, the driver the
# programs were written for
BGI_SHA256 = "3e37011adb4763ab027a555acee4a82aab3fcb0483611518b8eb1f282e972ee2"

# The fixed cycles keep the speed steady across machines and stay below the
# speed at which the unpatched Crt unit fails with runtime error 200
BUNDLE_DOSBOX_CONF = """\
[cpu]
cycles=fixed 3000

[autoexec]
@echo off
mount c .
c:
freepnt firework
echo Type FREEPNT FIREWORK to paint again, or FREEPNTV FIREWORK to view it.
"""

# A fixed date keeps the bundle byte-identical across builds; it is the date
# the help screens give
BUNDLE_DATE = (1995, 10, 20, 0, 0, 0)

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


def add_file(archive: zipfile.ZipFile, name: str, data: bytes, date: tuple) -> None:
    info = zipfile.ZipInfo(name, date)
    info.compress_type = zipfile.ZIP_DEFLATED
    archive.writestr(info, data)


def on_host(dos_path: str) -> Path:
    """Maps a DOS path on C: onto the host folder mounted as C:."""
    dos_c_dir = required_env("DOS_C_DIR", "the folder mounted as the DOS C: drive")
    return dos_c_dir.joinpath(*PureWindowsPath(dos_path).parts[1:])


def read_bgi() -> bytes:
    path = on_host(os.environ.get("BGI", DEFAULT_BGI))
    if not path.is_file():
        sys.exit(f"Not found: {path}")
    bgi = path.read_bytes()
    if hashlib.sha256(bgi).hexdigest() != BGI_SHA256:
        sys.exit(f"{path} is not the EGAVGA.BGI from Borland Pascal 7.0")
    return bgi


def compile_exes(build_dir: Path) -> dict[str, bytes]:
    dosbox = required_env("DOSBOX", "the DOSBox Staging executable")
    dos_c_dir = required_env("DOS_C_DIR", "the folder mounted as the DOS C: drive")
    tpc = os.environ.get("TPC", DEFAULT_TPC)

    for path in (dosbox, on_host(tpc)):
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


def write_bundle(exes: dict[str, bytes], bgi: bytes) -> None:
    WEB_BUNDLE.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(WEB_BUNDLE, "w") as archive:
        conf = BUNDLE_DOSBOX_CONF.encode("ascii")
        add_file(archive, ".jsdos/dosbox.conf", conf, BUNDLE_DATE)
        for name, exe in exes.items():
            add_file(archive, f"{name}.EXE", exe, BUNDLE_DATE)
        add_file(archive, "EGAVGA.BGI", bgi, BUNDLE_DATE)
        add_file(archive, SAMPLE.name, SAMPLE.read_bytes(), BUNDLE_DATE)
    print(f"Wrote {WEB_BUNDLE.relative_to(REPO_DIR).as_posix()}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--web", action="store_true", help="also write the js-dos bundle for web/"
    )
    args = parser.parse_args()

    # Checked first, so a wrong driver fails before the slow compile
    bgi = read_bgi() if args.web else b""

    with tempfile.TemporaryDirectory() as temp:
        exes = compile_exes(Path(temp) / "build")

    for name, exe in exes.items():
        digest = hashlib.sha256(exe).hexdigest()
        if digest == PROGRAMS[name]:
            print(f"{name}.EXE unchanged ({len(exe)} bytes, SHA-256 {digest[:12]})")
        else:
            print(f"{name}.EXE changed: SHA-256 is now {digest}")
            print("If the change is intended, update PROGRAMS in build.py")

    if args.web:
        write_bundle(exes, bgi)


if __name__ == "__main__":
    main()

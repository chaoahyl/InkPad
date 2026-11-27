"""在 Linux 上直接跑随手画的模型测试，不用编译整个 App。

用法：python3 Tests/run_model_tests.py
      python Tests/run_model_tests.py --wsl Ubuntu   （在 Windows 上，转到 WSL 里跑）

把 Models、Stores 和 ExportLayout 的源文件拼在一起，去掉 Linux 上没有的 Combine
（import Combine、ObservableObject、@Published），再接上 ModelTests.swift 运行。
测的都是正式代码本身。
"""

import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def kxbuild_header_args(swift, temporary):
    """KXBuild 的 Swift 工具链把 os、dispatch 这些 Linux C 模块目录改名成 os_org、dispatch_org，
    好让 iOS 构建用 Apple SDK 的头文件。Linux 上的 Foundation 还要用它们，在临时目录里链回原名。"""
    if not sys.platform.startswith("linux"):
        return []
    try:
        info = json.loads(subprocess.check_output([swift, "-print-target-info"], text=True))
        resources = Path(info["paths"]["runtimeResourcePath"])
    except (OSError, subprocess.CalledProcessError, KeyError, ValueError):
        return []
    renamed = [p for p in resources.glob("*_org") if p.is_dir() and not (resources / p.name[:-4]).exists()]
    if not renamed:
        return []
    headers = Path(temporary) / "headers"
    headers.mkdir()
    for folder in renamed:
        (headers / folder.name[:-4]).symlink_to(folder, target_is_directory=True)
    return ["-Xcc", f"-I{headers}"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--wsl", metavar="DISTRO")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    if args.wsl:
        mapped = subprocess.check_output(["wsl", "-d", args.wsl, "--exec", "wslpath", "-a", root.as_posix()], text=True).strip()
        script = 'cd "$1" && python3 Tests/run_model_tests.py'
        raise SystemExit(subprocess.call(["wsl", "-d", args.wsl, "--exec", "bash", "-lc", script, "--", mapped]))

    app = root / "InkPad"
    files = sorted((app / "Models").glob("*.swift")) + sorted((app / "Stores").glob("*.swift"))
    files.append(app / "Services/ExportLayout.swift")
    source = "\n".join(path.read_text(encoding="utf-8") for path in files)
    source = source.replace("import Combine\n", "").replace(": ObservableObject", "").replace("@Published ", "")
    tests = (root / "Tests/ModelTests.swift").read_text(encoding="utf-8")

    with tempfile.TemporaryDirectory(prefix="inkpad-tests-") as temporary:
        path = Path(temporary) / "main.swift"
        path.write_text("import Foundation\n" + source + "\n" + tests, encoding="utf-8")
        swift = shutil.which("swift")
        if not swift:
            parser.error("找不到 swift；请在装了 Swift 的 Linux 里运行，或在 Windows 上加 --wsl Ubuntu。")
        raise SystemExit(subprocess.call([swift, *kxbuild_header_args(swift, temporary), str(path)]))


if __name__ == "__main__":
    main()

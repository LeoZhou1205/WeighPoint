#!/usr/bin/env python3
"""Check publishable files or the Git index; never print credential values."""

import argparse
from pathlib import Path
import re
import subprocess
import sys


PATTERNS = {
    "Google API key": rb"AIza[A-Za-z0-9_-]{30,}",
    "GitHub token": rb"(?:gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,})",
    "service API key": rb"sk-(?:proj-|ant-)?[A-Za-z0-9_-]{20,}",
    "AWS access key": rb"(?:AKIA|ASIA)[A-Z0-9]{16}",
    "Slack token": rb"xox[baprs]-[A-Za-z0-9-]{20,}",
    "private key": rb"-----BEGIN (?:[A-Z0-9]+ )*PRIVATE KEY-----",
    "URL with credentials": rb"https?://[^\s/:]+:[^\s/@]+@",
    "literal credential": rb"(?i)(?:api_?key|client_?secret|password|access_?token|secret_?key)\s*(?::\s*String\s*)?[:=]\s*[\"'][A-Za-z0-9_+./=-]{20,}[\"']",
}


def git(*args):
    return subprocess.check_output(["git", *args])


def private_path(name):
    path = Path(name)
    if "xcuserdata" in path.parts:
        return True
    if path.name in {"Local.xcconfig", "Secrets.plist", "GoogleService-Info.plist", "credentials.json", ".env"}:
        return True
    if path.name.startswith(".env.") and path.name not in {".env.example", ".env.sample"}:
        return True
    return path.name.endswith(".local.xcconfig") or path.suffix in {
        ".pem", ".key", ".p12", ".p8", ".mobileprovision", ".provisionprofile",
        ".xcuserstate", ".sqlite", ".sqlite3", ".db", ".store",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--staged", action="store_true", help="Scan exact staged contents, including unchanged tracked files.")
    args = parser.parse_args()
    root = Path(git("rev-parse", "--show-toplevel").decode().strip())
    import os
    os.chdir(root)
    flags = ["ls-files", "-z", "--cached"]
    if not args.staged:
        flags += ["--others", "--exclude-standard"]
    names = sorted(set(git(*flags).decode().rstrip("\0").split("\0")) - {""})
    failures = []
    for name in names:
        if private_path(name):
            failures.append(f"{name}: private file must not be committed")
            continue
        if args.staged:
            data = git("show", f":{name}")
        else:
            path = root / name
            if not path.exists():
                continue
            data = path.read_bytes()
        for label, pattern in PATTERNS.items():
            for match in re.finditer(pattern, data):
                line = data.count(b"\n", 0, match.start()) + 1
                failures.append(f"{name}:{line}: possible {label} (value withheld)")
    if failures:
        print("Secret check failed:", file=sys.stderr)
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"Secret check passed: {len(names)} files scanned.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

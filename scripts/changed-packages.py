#!/usr/bin/env python3
"""Print a CI matrix for changed package directories; never evaluate PKGBUILD."""
import argparse
import json
import re
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--base', default='')
parser.add_argument('--head', default='HEAD')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
packages = sorted(p.parent.name for p in (root / 'packages').glob('*/PKGBUILD')
                  if not p.parent.is_symlink())
if any(not re.fullmatch(r'[a-z0-9][a-z0-9+_.-]*', p) for p in packages):
    raise SystemExit('Invalid package directory name')
if not args.base or set(args.base) == {'0'}:
    selected = packages
else:
    result = subprocess.run(['git', 'diff', '--name-only', '--no-renames',
                             args.base, args.head, '--'], cwd=root,
                            check=True, capture_output=True, text=True)
    files = result.stdout.splitlines()
    if any(p.startswith(('scripts/', '.github/workflows/')) for p in files):
        selected = packages
    else:
        changed = {p.split('/')[1] for p in files
                   if p.startswith('packages/') and len(p.split('/')) > 2}
        selected = [p for p in packages if p in changed]
print(json.dumps({'package': selected}))

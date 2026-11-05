#!/usr/bin/env python3
"""Report upstream versions; never change PKGBUILD or publish automatically."""
from pathlib import Path
import argparse
import json
import re
import urllib.request
from urllib.parse import urlparse

parser = argparse.ArgumentParser()
parser.add_argument("--fixture", help="read a saved official JSONP response")
args = parser.parse_args()
if args.fixture:
    text = open(args.fixture).read()
else:
    url = "https://appversion.115.com/1/web/1.0/api/chrome?callback=get_version"
    with urllib.request.urlopen(url, timeout=30) as response:
        text = response.read().decode()
match = re.fullmatch(r"\s*get_version\((.*)\);?\s*", text, re.S)
if not match:
    raise SystemExit("ERROR: unexpected official API format; manual review required")
data = json.loads(match[1])
if not data.get("state"):
    raise SystemExit("ERROR: official version API failed")
# linux is the browser, linux_115 is the Life client; never mix products.
info = data.get("data", {}).get("linux_115", {})
version = info.get("version_code", "")
url = info.get("version_url", "")
parsed = urlparse(url)
if (parsed.scheme != "https" or parsed.netloc != "down.115.com"
        or not re.fullmatch(r"/client/115pc/lin/115Life_[0-9]+(?:\.[0-9]+)+\.deb", parsed.path)
        or not re.fullmatch(r"[0-9]+(?:\.[0-9]+)+", version)
        or parsed.path.rsplit("/", 1)[-1] != f"115Life_{version}.deb"):
    raise SystemExit("ERROR: official Life Linux metadata is unavailable/invalid; "
                     "cannot confirm latest version. Review https://115.com/ manually.")
current = re.search(r"^pkgver=(.+)$", (Path(__file__).resolve().parents[1] / "packages/115life-desktop-bin/PKGBUILD").read_text(), re.M)[1]
print(json.dumps({"current": current, "upstream": version, "url": url,
                  "update_available": tuple(map(int, version.split("."))) >
                  tuple(map(int, current.split(".")))}, ensure_ascii=False))

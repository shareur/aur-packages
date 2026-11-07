#!/usr/bin/env bash
set -euo pipefail
archive=$1
reports=$2
bsdtar -xOf "$archive" usr/share/applications/chatgpt.desktop > "$reports/chatgpt.desktop"
desktop-file-validate "$reports/chatgpt.desktop"
bsdtar -tf "$archive" > "$reports/paths.txt"
# Launcher and application payload must stay where the vendor binaries expect them.
bsdtar -tvf "$archive" | grep -E ' usr/bin/chatgpt -> \.\./lib/chatgpt/codex-launcher$'
for path in usr/lib/chatgpt/ChatGPT usr/lib/chatgpt/codex-launcher \
            usr/lib/chatgpt/resources/app.asar usr/lib/chatgpt/resources/codex \
            usr/share/pixmaps/chatgpt.png etc/apparmor.d/chatgpt \
            "usr/share/licenses/chatgpt-bin/copyright"; do
    grep -qxF "$path" "$reports/paths.txt"
done
# Debian-only metadata must not leak into the package.
if grep -qE '^usr/share/(doc|lintian)/' "$reports/paths.txt"; then
    echo 'Unexpected Debian documentation/lintian payload' >&2; exit 1
fi
# Electron sandboxing stays intact: no --no-sandbox in the launcher, no setuid helper.
bsdtar -xOf "$archive" usr/lib/chatgpt/codex-launcher > "$reports/codex-launcher"
# Compare the vendor launcher text literally; the $ expressions must not expand.
# shellcheck disable=SC2016
grep -qxF 'exec "$(dirname "$(readlink -f "$0")")/ChatGPT" "$@"' "$reports/codex-launcher"
if bsdtar -tvf "$archive" | grep -qE '^-rws'; then
    echo 'Unexpected setuid payload' >&2; exit 1
fi

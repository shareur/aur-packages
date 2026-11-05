#!/usr/bin/env bash
set -euo pipefail
archive=$1
reports=$2
bsdtar -xOf "$archive" usr/share/applications/life115.desktop > "$reports/life115.desktop"
desktop-file-validate "$reports/life115.desktop"

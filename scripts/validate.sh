#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if (( $# == 0 )); then
    for recipe in "$root"/packages/*/PKGBUILD; do
        [[ -f $recipe ]] || continue
        package=$(basename "$(dirname "$recipe")")
        bash "$root/scripts/validate.sh" "$package"
    done
    exit 0
fi
for package in "$@"; do
    [[ $package =~ ^[a-z0-9][a-z0-9+_.-]*$ ]] || exit 2
    directory="$root/packages/$package"
    [[ -f $directory/PKGBUILD && ! -L $directory ]] || exit 2
    reports="$root/reports/$package"
    mkdir -p "$reports"
    (
        cd "$directory"
        makepkg --force --verifysource
        makepkg --force --noconfirm
        makepkg --printsrcinfo > "$reports/SRCINFO.generated"
        diff -u .SRCINFO "$reports/SRCINFO.generated"
        [[ $(awk '$1 == "pkgbase" && $2 == "=" {print $3}' .SRCINFO) == "$package" ]]
        mapfile -t archives < <(makepkg --packagelist)
        (( ${#archives[@]} > 0 ))
        namcap PKGBUILD "${archives[@]}" 2>&1 | tee "$reports/namcap.log"
        # Vendor /opt layout waiver is scoped to this package only.
        diagnostics=$(grep -E ' E: |^Error:|Traceback' "$reports/namcap.log" || true)
        if [[ $package == 115life-desktop-bin ]]; then
            diagnostics=$(printf '%s\n' "$diagnostics" | grep -vFx "115life-desktop-bin E: ELF files outside of a valid path ('opt/')." || true)
        fi
        [[ -z $diagnostics ]] || { printf '%s\n' "$diagnostics" >&2; exit 1; }
        if [[ -f check-package.sh ]]; then
            bash check-package.sh "${archives[0]}" "$reports"
        fi
        bsdtar -tvf "${archives[0]}" > "$reports/manifest.txt"
        sha256sum "${archives[@]}" > "$reports/package-sha256.txt"
    )
done

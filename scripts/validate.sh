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
        if [[ $package == 115life-desktop-bin || $package == 115life-browser-bin ]]; then
            diagnostics=$(printf '%s\n' "$diagnostics" | grep -vFx "$package E: ELF files outside of a valid path ('opt/')." || true)
        fi
        # Upstream Flutter plugins carry a RUNPATH pointing at the vendor build
        # directory. It never exists on Arch, it cannot be created by an unprivileged
        # user, and removing it would require rewriting vendor ELF headers with
        # patchelf, which this recipe deliberately does not do.
        if [[ $package == rustdesk-unattended-wayland ]]; then
            diagnostics=$(printf '%s\n' "$diagnostics" | grep -vF "$package E: Insecure RUNPATH '/workspace/flutter/linux/flutter/ephemeral' in file ('usr/lib/rustdesk/lib/" || true)
        fi
        # chatgpt-bin ships payload files for other platforms and for runtimes it
        # bundles itself. These diagnostics are produced by files that never run on
        # Arch: ARM/32-bit .node prebuilds (lib32-*), a .jar data file inside a
        # device-tool module (java-runtime), node shebang scripts executed with the
        # bundled Node runtime (nodejs), and optional imports inside bundled Python
        # helpers and skills (python-numpy, python-pillow). Real library needs
        # (tpm2-tss, libusb) are declared; python is an optdepend.
        if [[ $package == chatgpt-bin ]]; then
            for dep in lib32-gcc-libs lib32-glibc lib32-systemd java-runtime \
                       nodejs python-numpy python-pillow; do
                diagnostics=$(printf '%s\n' "$diagnostics" | grep -vF "$package E: Dependency $dep detected and not included" || true)
            done
        fi
        [[ -z $diagnostics ]] || { printf '%s\n' "$diagnostics" >&2; exit 1; }
        if [[ -f check-package.sh ]]; then
            bash check-package.sh "${archives[0]}" "$reports"
        fi
        bsdtar -tvf "${archives[0]}" > "$reports/manifest.txt"
        sha256sum "${archives[@]}" > "$reports/package-sha256.txt"
    )
done

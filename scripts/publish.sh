#!/usr/bin/env bash
# Default: show a local diff only. --push explicitly commits and publishes.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
package=${1:?Usage: publish.sh PACKAGE AUR_CHECKOUT [--push]}
checkout=${2:?Specify an existing independent AUR Git checkout}
mode=${3:---dry-run}
[[ $package =~ ^[a-z0-9][a-z0-9+_.-]*$ ]] || exit 2
[[ $mode == --dry-run || $mode == --push ]] || exit 2
source_dir="$root/packages/$package"
[[ -f $source_dir/PKGBUILD && ! -L $source_dir ]] || exit 2
[[ $(awk '$1 == "pkgbase" && $2 == "=" {print $3}' "$source_dir/.SRCINFO") == "$package" ]] || exit 2
checkout=$(cd -- "$checkout" && pwd -P)
[[ $(git -C "$checkout" rev-parse --show-toplevel) == "$checkout" ]] || exit 2
remote=$(git -C "$checkout" remote get-url origin)
[[ $remote == "ssh://aur@aur.archlinux.org/$package.git" || $remote == "aur@aur.archlinux.org:$package.git" ]] || {
    echo 'Origin must be the matching official AUR repository' >&2; exit 1;
}
[[ -z $(git -C "$checkout" status --porcelain) ]] || {
    echo 'AUR checkout has uncommitted changes; review them first' >&2; exit 1;
}
# Keep uploads explicit. List additional local sources/install files here later.
files=(PKGBUILD .SRCINFO)
if [[ -f $source_dir/.aur-files ]]; then
    while IFS= read -r file || [[ -n $file ]]; do
        [[ -z $file || $file == \#* ]] && continue
        [[ $file =~ ^[a-zA-Z0-9_.+-]+$ && $file != . && $file != .. ]] || exit 2
        files+=("$file")
    done < "$source_dir/.aur-files"
fi
for file in "${files[@]}"; do
    [[ -f $source_dir/$file && ! -L $source_dir/$file ]] || exit 2
    [[ ! -L $checkout/$file ]] || { echo 'Refusing a symlink in AUR checkout' >&2; exit 1; }
    if [[ -f $checkout/$file ]]; then
        diff -u "$checkout/$file" "$source_dir/$file" || [[ $? == 1 ]]
    else
        printf 'New AUR file: %s\n' "$file"
    fi
done
if [[ $mode != --push ]]; then
    echo 'Preview only; no files copied, commits created or network writes performed.'
    exit 0
fi
if grep -q 'set your name and email' "$source_dir/PKGBUILD"; then
    echo 'Fill in the PKGBUILD Maintainer before publishing' >&2; exit 1
fi
# The caller must review PKGBUILD before executing makepkg metadata generation.
generated=$(mktemp)
trap 'rm -f "$generated"' EXIT
(cd "$source_dir" && makepkg --printsrcinfo) > "$generated"
diff -u "$source_dir/.SRCINFO" "$generated"
for file in "${files[@]}"; do cp -- "$source_dir/$file" "$checkout/$file"; done
git -C "$checkout" add -- "${files[@]}"
if git -C "$checkout" diff --cached --quiet; then
    echo 'AUR checkout already matches this recipe'; exit 0
fi
git -C "$checkout" commit -m "Update reviewed $package recipe"
git -C "$checkout" push origin HEAD:master

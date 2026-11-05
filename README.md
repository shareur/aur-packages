# aur-packages

Arch Linux / CachyOS packaging recipes maintained by **Yang** (<shareur@imyang.me>) in
[shareur/aur-packages](https://github.com/shareur/aur-packages).

[简体中文](docs/zh-cn/README.md)

GitHub `master` is the source of truth. **GitHub-only publication for now:**
the maintainer cannot register an AUR account, so these recipes are not yet
published to AUR. Automatic AUR publishing is disabled.

| Package | Recipe version | Verification |
| --- | --- | --- |
| [115life-desktop-bin](packages/115life-desktop-bin/) | 37.3.2-3 | Local runtime verified under former name; renamed package pending installation test |

## Install

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/115life-desktop-bin
makepkg -si
```

Review PKGBUILD first and run makepkg as a regular user. Sources are downloaded
from the vendor and checked against pinned SHA256. No vendor DEB or built binary
packages are hosted here. See the package guide for dependencies and limitations.

Update with `git pull --ff-only`, then run `makepkg -si` in the package directory.
Remove with `sudo pacman -R 115life-desktop-bin`; settings and downloaded files remain.

## Maintain and validate

Recipes and supporting files belong in `packages/<pkgbase>/`; shared tooling is
in `scripts/`, workflows in `.github/workflows/`.

```bash
# From repository root; omit the package argument to validate all packages.
bash scripts/validate.sh 115life-desktop-bin
shellcheck scripts/*.sh
# Close the client first: installs/removes/restores the host package using sudo.
bash scripts/test-local-install.sh 115life-desktop-bin
```

Update upstream version/checksum and regenerate `.SRCINFO` when metadata changes.
Validate before committing. Logs live in `reports/<pkgbase>/`; downloads, build
outputs and local inspection data are ignored. Optional package-specific
`check-package.sh` receives the archive path and report directory.

CI selects changed packages, builds each in a disposable Arch container, checks
installation and removal, and uploads **reports only**. For 115life-desktop-bin it also
requires a visible client window under Xvfb. This does not replace KDE/account,
transfer or playback testing. Historical local results are in
[VALIDATION.md](packages/115life-desktop-bin/VALIDATION.md); consult Actions for CI results.

The vendor's Life Linux version metadata is currently invalid. The upstream
checker is manual-only, never updates recipes and never publishes. The packaged
version is not claimed to be the latest release.

## Future AUR publication

After registration becomes available, verify account access and package-name
availability. Each pkgbase uses its own AUR repository. The manual helper defaults
to a read-only preview; `--push` commits and publishes and requires explicit
authorization. See [the publishing plan](docs/automation.md); old `.disabled`
workflow examples are historical references, not ready-to-enable automation.

Repository-authored recipes, scripts and documents are MIT licensed. Third-party
applications and bundled components retain their upstream licenses; this license
does not grant permission to redistribute proprietary binaries.

Naming: `115life-desktop-bin` is the Life desktop client; `115life-browser-bin`
is reserved for a future browser recipe. Both use upstream DEBs as binary inputs,
without compiling source code. Only the desktop recipe exists in this repository.

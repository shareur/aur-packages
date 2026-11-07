# rustdesk-unattended-wayland

Official **RustDesk** Linux build for unattended access on Wayland, repackaged for
Arch Linux / CachyOS x86_64. Maintainer: **Yang <shareur@imyang.me>**.
Recipe version: **1.5.1-1**.

[简体中文](../../docs/zh-cn/packages/rustdesk-unattended-wayland/README.md)

## Which upstream build this is

RustDesk publishes several Linux packages. This recipe uses the
`rustdesk-unattended-wayland` DEB, which ships the vendor `libdrmtap` helper in
`/usr/lib/rustdesk/`. That helper captures DRM/KMS scanout without an interactive
screen-share prompt, and the client falls back to PipeWire / XDG Desktop Portal
capture when DRM capture is unavailable. The vendor binaries are repackaged
unchanged; no source code is compiled and no Rust toolchain is needed.

The package name mirrors the upstream artefact rather than the usual `-bin`
suffix; it is still a binary repackage of an official DEB.

## Install

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/rustdesk-unattended-wayland
makepkg -si
rustdesk
```

Run `makepkg` as a regular user. The recipe downloads the pinned official DEB from
GitHub releases and verifies SHA256 before packaging. Update by pulling the
repository and running `makepkg -si` again; remove with
`sudo pacman -R rustdesk-unattended-wayland`. User configuration in
`~/.config/rustdesk` and received files remain.

The package declares `provides`/`conflicts` for `rustdesk`, matching the vendor
control data. It therefore cannot be installed next to another package that
provides `rustdesk` (for example `rustdesk-bin`); pacman will ask to remove the
conflicting package in the same transaction.

## Unattended access

The recipe installs `/usr/lib/systemd/system/rustdesk.service` but deliberately
does not enable or start it. Arch packages never switch on a root service by
themselves, because doing so makes this machine reachable over the network.

Enable it only after reviewing the connection settings and setting a permanent
password in the client:

```bash
sudo systemctl enable --now rustdesk   # start the service now and at boot
systemctl status rustdesk
sudo systemctl disable --now rustdesk  # stop it and remove it from boot
```

The unit runs `/usr/bin/rustdesk --service` as root, which is what allows a
connection before anyone logs in to the desktop. It is shipped with one packaging
change only: `ExecStop` uses the absolute `/usr/bin/pkill`, because systemd rejects
non-absolute executable paths. No firewall rule, port forward or relay
configuration is added or changed by this package.

## Package layout and deviations from the DEB

- The vendor application tree is installed to `/usr/lib/rustdesk` instead of
  `/usr/share/rustdesk`, because ELF files must not live under `/usr/share`. The
  internal layout (launcher, `lib/`, `data/`) is unchanged, so the launcher's
  `$ORIGIN/lib` runpath and Flutter's `data/` lookup keep working.
- `/usr/lib/rustdesk/libdrmtap.so.0*` therefore sits in the same directory and
  still matches the absolute path compiled into `librustdesk.so`; moving it
  elsewhere would disable DRM capture.
- `/usr/bin/rustdesk` is a symlink to `/usr/lib/rustdesk/rustdesk`, created at
  build time because the recipe never runs Debian maintainer scripts.
- The vendor unit is installed under `/usr/lib/systemd/system/`; the Debian
  `postinst`/`prerm`/`postrm` scripts are inspected but not executed.
- The payload is not stripped and no debug package is split, matching the other
  binary recipes in this repository.

## Verification and limits

From the repository root:

```bash
bash scripts/validate.sh rustdesk-unattended-wayland
# Interactive sudo; installs, checks and removes the package, then restores it.
bash scripts/test-local-install.sh rustdesk-unattended-wayland
```

`/usr/bin/rustdesk --version` prints `1.5.1` and is used as a headless smoke check.
Validation covers the source checksum, build, `.SRCINFO` consistency, namcap,
desktop-file syntax, package layout (launcher symlink, DRM helper, unit file) and
the dependency list derived from ELF inspection of the shipped binaries.

Not covered: an installed GUI session, a real unattended connection, DRM capture
on a Wayland compositor, PipeWire/portal fallback and the systemd service actually
running. A successful build and version command are not evidence for any of them.

## Licensing

RustDesk is licensed under **AGPL-3.0-only** upstream. This DEB does not contain a
standalone license file; third-party notices ship inside the payload as
`/usr/lib/rustdesk/data/flutter_assets/NOTICES.Z`, which the package keeps
unchanged. This repository only maintains recipes; it does not host the DEB or any
built binary package, and its own MIT license does not relicense RustDesk or the
bundled components.

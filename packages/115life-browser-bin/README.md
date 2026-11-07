# 115life-browser-bin

Official **115 Browser** DEB repackaged for Arch Linux / CachyOS x86_64.
Maintainer: **Yang <shareur@imyang.me>**. Recipe version: **36.0.1-1**.

[简体中文](../../docs/zh-cn/packages/115life-browser-bin/README.md)

## Install and use

```bash
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/115life-browser-bin
makepkg -si
115life-browser
```

Run as a regular user. The menu entry is **115浏览器**. On KDE Wayland, XWayland,
appropriate drivers and fonts may be needed. Pull updates and rerun `makepkg -si`;
remove with `sudo pacman -R 115life-browser-bin`. User profiles/downloads remain.

The DEB's `/usr/local/115Browser` payload is relocated to `/opt/115Browser` and its
launcher/desktop paths are updated. Vendor library loading and resources remain
intact. The vendor `chrome-sandbox` helper is installed root-owned with mode 4755,
as required by its postinst; that script is inspected but never executed. No
`--no-sandbox` flag is added, and no default browser or user settings are changed.

The Life desktop recipe uses `/opt/115life` and different desktop/icon IDs, so the
two package payloads can coexist. They remain separate applications.

## Verification and limits

From the repository root:

```bash
bash scripts/validate.sh 115life-browser-bin
# Interactive sudo; installs/removes/restores the browser. Close it first.
bash scripts/test-local-install.sh 115life-browser-bin
```

The official DEB SHA256 was independently downloaded and compared. Tests cover
metadata, desktop syntax, relocated paths and root-owned 4755 sandbox permissions.
The main binary's version command reports **115Browser 125.0.6422.61**; this differs
from product version 36.0.1. Repackaging does not update the Chromium engine.
See [VALIDATION.md](VALIDATION.md) for actual checks and remaining limitations.

The exact namcap `/opt` layout diagnostic is accepted only for the named vendor
packages. Vendor bundled-library/RELRO and optional Qt shim warnings are recorded;
no blanket error suppression is used. Qt 5/6 integration is optional; GTK3 is a
required dependency. The vendor OpenSSL 1.1 libraries remain app-local.

CI installs and removes the browser and checks `--version`; browser GUI, sandbox,
login, transfer and playback still require real desktop testing. No host install
or GUI test is implied by a successful binary build or version command.

## Licensing and publication

The supplied DEB has no standalone license or third-party notice file. The local
`LICENSE` source records this limitation and points to vendor copyright information
and `chrome://credits`; it is not a vendor license grant. Review upstream terms
before redistributing binaries or submitting to AUR. Only recipes are maintained
here; automatic AUR publication is disabled. `.aur-files` includes the local
license-information source required to build this package from an AUR checkout.

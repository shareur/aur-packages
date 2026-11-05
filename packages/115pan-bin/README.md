# 115pan-bin

Official 115 Life Linux x86_64 DEB repackaged for Arch Linux / CachyOS.
Maintainer: **Yang**. Recipe version: **37.3.2-2**. This is 115 Life, not 115 Browser.

[中文说明](../../docs/zh-cn/packages/115pan-bin/README.md)

## Install

```bash
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/115pan-bin
makepkg -si
```

Run `makepkg` as a regular user. It retrieves the pinned official DEB and verifies
SHA256 before packaging. The self-contained .NET runtime and app-local ICU stay
bundled; GTK3, WebKitGTK and other runtime dependencies come from Arch packages.
On KDE Wayland, install XWayland and appropriate graphics drivers/fonts.

Launch **115生活** from the menu, or run `115pan` / `115life`. Update by pulling the
repository and running `makepkg -si` again. Keep `/opt/115life` managed by pacman;
do not use an in-app updater to overwrite package files. Remove with
`sudo pacman -R 115pan-bin`; user settings and downloaded files remain.

## Verification and limitations

From the repository root, run `bash scripts/validate.sh 115pan-bin`. The optional
`bash scripts/test-local-install.sh 115pan-bin` changes the host installation,
checks removal and restores the package; close the client first.

Local installation, KDE menu/login window, removal and restoration were verified.
Account login, file transfer and playback still need user testing. Historical
results are in [VALIDATION.md](VALIDATION.md); CI reports are separate evidence.

The exact namcap diagnostic `ELF files outside of a valid path ('opt/').` is
accepted only for this package to preserve vendor paths. Vendor FULL RELRO,
unused-library and dynamic-dependency warnings remain documented. Optional
`lttng-ust` supports .NET tracing; ICU SONAME links use the bundled ICU version.

The official version API currently exposes invalid Life Linux metadata. Version
checking is manual-only and fails clearly on invalid responses; **37.3.2 is not
claimed to be the latest release**.

## Distribution

Published on GitHub as recipes only; not yet available on AUR because the
maintainer cannot register an account. No binary assets are distributed. The
vendor license restricts proprietary redistribution; this repository does not
grant permission to redistribute the application. Third-party bundled components
retain their own licenses. Automatic AUR publication remains disabled.

# Validation log (2026-11-05)

The records below describe the former package `115pan-bin`; renaming a package does
not turn earlier tests into evidence for the new name.

[简体中文](../../docs/zh-cn/packages/115life-desktop-bin/VALIDATION.md)

## Upstream and environment

- Host: CachyOS x86_64, KDE Wayland. `makepkg` is available; namcap 3.6.0-3 runs from
  the project `tools/` directory because sudo on this host requires an interactive
  password.
- Official file: https://down.115.com/client/115pc/lin/115Life_37.3.2.deb
- The local file and a fresh download of the official file have the same SHA256:
  `b6530f321787c5e7ea4c00ccd0bc6eee1d99b5997f8cda8f701d0dd00c022f7e`.
- DEB control: 115life 37.3.2 amd64; self-contained .NET 10.0.10, Avalonia and ICU
  72.1.0.3; main program `/opt/115life/Life115`. Third-party licenses are under
  `/opt/115life/Licenses`.
- The vendor home page points to pc.115.com, which uses
  `appversion.115.com/1/web/1.0/api/chrome?callback=get_version`. Its `linux` field is
  115 Browser 36.0.1 and `linux_115` is an older version whose URL points at a
  loopback address. The endpoint therefore cannot confirm the latest 115 Life
  version; the checker fails explicitly and never treats the browser version as a
  Life upgrade.

## Packaging decisions

- Only data.tar.xz is extracted; postinst/prerm/postrm are not executed and no shared
  mimeapps.list or root user configuration is written. Desktop and icon caches are
  left to the Arch pacman hooks.
- The official desktop ID `life115.desktop`, protocol and torrent MIME declarations
  are kept; the `115pan` command was added and `115life` retained.
- No stripping and no debug split, keeping the official prebuilt files. The license is
  declared as LicenseRef-115-Proprietary and license files are installed.
- The DEB records the 115life symlink as 0755; it is recreated as the standard 0777,
  which fixed the pacman -Qkk permission diagnostic on first installation.
- Three bundled ICU SONAME links are added so the bundled ICU ABI is used instead of
  the system ICU.
- GTK/WebKitGTK/libsecret/libnotify/OpenSSL are loaded dynamically by managed code;
  Avalonia.X11.dll shows load names for libX11, ICE, SM, Xi, Xext, Xrandr, Xcursor and
  GL, which are declared dependencies. libffcore needs libva/libva-drm/fontconfig.
  gcc-libs is kept as the Arch runtime aggregation package.

## Executed checks and limits

- makepkg build, SHA256, desktop-file-validate and namcap were run; the license SPDX
  identifier and the missing ICU SONAME links were fixed.
- namcap still reports the official /opt layout (explicitly waived), FULL RELRO for
  vendor libraries, unused libraries and possibly unnecessary dynamically loaded
  dependencies; this is not a zero-warning state. Without the optional tracing
  library installed there is a liblttng-ust warning.
- The user installed 37.3.2-1 and confirmed the KDE menu is visible and opens the
  login window. The autostart command printed nothing and returned 0 immediately,
  which alone is not GUI evidence; the desktop result rests on user confirmation.
- 37.3.2-2 added runtime library dependencies, ICU links and the symlink permission
  fix. The user ran `scripts/test-local-install.sh`, which upgraded, verified removal
  and restored the package; pacman -Qkk reported `387 total files, 0 altered files`,
  the removal check printed `Removal verified; restoring package.`, and the desktop
  and icon cache hooks ran correctly.
- Upload, download, account login, video playback and protocol handling still need
  user testing; no user account was used for these operations.
- The CI YAML was syntax-checked locally, but the container tests have not run on
  GitHub, so CI cannot be claimed to pass. The version checker was verified against
  the real official response as a safe failure, and five cases were covered: valid
  version, newer version, loopback URL, wrong product and filename/version mismatch.
  Embedded shell in the workflows passed `bash -n`; scripts passed shellcheck.
- Nothing was published publicly, no binaries were uploaded, no remote repository was
  created and nothing was pushed to AUR; publishing stays disabled and requires human
  approval.

## Monorepo migration validation

- The project was reorganised into `packages/115pan-bin/` with PKGBUILD and .SRCINFO
  unchanged; the original DEB, build outputs and historical logs stay local and are
  excluded from version control.
- After the migration the shared `scripts/validate.sh 115pan-bin` was called from
  outside the repository; makepkg, SHA256, namcap, desktop file and metadata
  consistency checks completed, and the existing upstream binary diagnostics
  remained.
- Change detection was verified for four cases: first full run, single package change,
  shared script change and documentation-only change.
- Manual publishing was verified to preview only, with the Git checkout left clean;
  invalid package names and a wrong AUR origin are rejected.
- ShellCheck, workflow YAML and embedded Bash syntax checks passed. GitHub CI has not
  run remotely.
- Automatic publishing stays disabled in this phase; the old single-package workflows
  moved to the `.disabled` templates under docs. Only validate.yml and upstream.yml
  remain executable.

## Rename to 115life-desktop-bin

- The maintainer address changed to shareur@imyang.me and the recipe was revised to
  37.3.2-3.
- The new package provides the old name and conflicts with the old package to allow a
  same-transaction migration; no `replaces` was added, so system packages are not
  replaced proactively.
- A `115life-desktop` launcher was added; the `115pan` and `115life` compatibility
  commands are kept.
- The upstream DEB, version and SHA256 are unchanged; the future browser recipe uses
  the separate name 115life-browser-bin.
- For the new package 37.3.2-3, the makepkg build, SHA256, .SRCINFO consistency,
  namcap (keeping the existing upstream diagnostics), desktop file and ShellCheck
  checks are done; the artefacts include the new launcher and the old
  provides/conflicts metadata.
- Installation, migration and GUI runtime of the new name have not been performed;
  the host installation was not modified and remote CI has not run for the rename.

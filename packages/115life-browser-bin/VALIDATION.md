# Validation: 115life-browser-bin 36.0.1-1

- Upstream DEB: https://down.115.com/client/115pc/lin/115br_v36.0.1.deb
- Local DEB and a fresh official download match SHA256:
  `a26f84625b5c1ca1a7f6e2eb5a89327c49627fb7f04db1b71e27c48904b88d8b`.
- DEB metadata: `115browser`, 36.0.1, amd64. No standalone license/notice file
  was found in the payload; the local LICENSE is an information notice only.
- Vendor postinst only sets launcher permissions and the Chromium helper's
  root ownership / 4755 mode. It is not executed by this recipe.
- The payload is moved from /usr/local/115Browser to /opt/115Browser. Vendor
  desktop ID 115Browser.desktop is retained, with a standard icon and command.
- ELF inspection identifies GTK3, NSS/NSPR, ALSA, CUPS, GBM/Mesa, AT-SPI, X11,
  XCB and other declared system libraries. Bundled curl also needs libidn2/zlib.
  Optional Qt5/Qt6 shims are retained and their dependencies are optdepends.
- The uninstalled upstream main binary was run with its app-local library path
  and --version; output: `115Browser 125.0.6422.61`. This is not a GUI test.
- Repackaging preserves vendor binaries and app-local OpenSSL 1.1; no source
  compilation, sandbox-disable flag or system MIME-default registration occurs.
- Local makepkg build, SHA256, .SRCINFO consistency, namcap, desktop-file syntax,
  archive path and root-owned 4755 sandbox checks passed. The package-specific
  /opt diagnostic is explicitly accepted; vendor RELRO, setuid, optional Qt5,
  app-local OpenSSL and unused-library warnings remain recorded in reports.
  The vendor desktop comment duplicates its name, a non-fatal validator warning.
- ShellCheck, local documentation links, workflow YAML and two-package matrix
  discovery passed. The two built archives contain no overlapping non-directory
  payload files; this is file-level evidence, not an installed coexistence test.
- Host installation/removal, sandboxed GUI startup, login, transfer and playback
  are not tested. Remote CI has not run for this uncommitted package.

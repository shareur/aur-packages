# Validation: rustdesk-unattended-wayland 1.5.1-1

- Upstream DEB: https://github.com/rustdesk/rustdesk/releases/download/1.5.1/rustdesk-unattended-wayland-1.5.1-x86_64.deb
- The local DEB and a fresh download of that official asset match SHA256
  `f7760dad505b5eca1e99531f15b4de21e83acc7dbfce77a3ba456ef2afb0e961`.
- DEB control: `rustdesk-unattended-wayland` 1.5.1, amd64, with
  `Provides`/`Conflicts`/`Replaces: rustdesk`. Debian `Depends` list GTK3, xcb-randr,
  xcb-shape, xcb-xfixes, libxdo, libxfixes, ALSA, libsystemd, curl, VA-API,
  GStreamer pipewire, libdrm, libEGL/libGLES2 and libc;
  `Recommends: libayatana-appindicator3-1`.
- Maintainer scripts were read, not executed. `postinst` creates `/usr/bin/rustdesk`,
  copies the unit into `/usr/lib/systemd/system/` and runs
  `systemctl daemon-reload/enable/start`; `prerm` stops the service and removes the
  launcher and unit; `postrm purge` deletes `/root/.config/rustdesk`. The recipe
  replicates only the launcher and the unit installation.
- ELF inspection of `rustdesk` (Flutter/Gtk launcher), `librustdesk.so`,
  `libflutter_linux_gtk.so` and `libdrmtap.so.0.5.12` produced the declared
  dependency list: glibc, gcc-libs, zlib, glib2, gtk3, gdk-pixbuf2, pango, cairo,
  at-spi2-core, libepoxy, fontconfig, dbus, libpulse, gstreamer, gst-plugins-base,
  libx11, libxfixes, libxtst, libxcb, libxkbcommon, wayland, libdrm, libva and
  libglvnd. `dlopen` strings additionally reference `libxdo` (xdotool),
  `libxkbcommon-x11`, `libXi`, `libva-drm`/`libva-x11`, both AppIndicator
  libraries, and the optional NVIDIA NVENC and Intel media stacks.
- No reference to libcurl, libsystemd, libpam, libvdpau or libasound was found in
  the shipped binaries, so those Debian dependencies were not copied into the Arch
  depends list: audio goes through libpulse, and `procps-ng` is declared because
  the unit's `ExecStop` calls `/usr/bin/pkill`.
- `librustdesk.so` contains the absolute string `/usr/lib/rustdesk/libdrmtap.so.0`,
  and the launcher's RUNPATH is `$ORIGIN/lib`. The application tree is therefore
  installed to `/usr/lib/rustdesk/` — a valid ELF location — with
  `libdrmtap.so.0*` in the same directory, which keeps both lookups working. No
  shipped binary references `/usr/share/rustdesk`.
- The vendor unit is installed unchanged except for `ExecStop=pkill` →
  `/usr/bin/pkill`, which systemd requires to be absolute.
- Running the packaged but uninstalled tree prints `1.5.1` for `--version`.
- Local `makepkg` build, `.SRCINFO` consistency, namcap, desktop-file syntax and the
  launcher / DRM library / unit layout assertions passed.
- `scripts/validate.sh` stops at makepkg's runtime dependency check on this host
  because `xdotool` is not installed. The package was built with
  `makepkg --nodeps` and the remaining validation steps were executed individually,
  so **dependency resolution is not verified locally**; `xdotool` must be present
  for `makepkg -si` and for CI.
- namcap reports 9 `Insecure RUNPATH '/workspace/flutter/linux/flutter/ephemeral'`
  diagnostics for the vendor Flutter plugins. `scripts/validate.sh` accepts exactly
  that diagnostic for this package only: it points at a vendor build directory that
  does not exist on Arch, cannot be created by an unprivileged user, and is only
  consulted after the real library paths; removing it would require rewriting
  vendor ELF headers with patchelf. Other diagnostics are recorded, not suppressed:
  11 FULL RELRO, 11 unstripped binaries, 1 non-PIE helper, 87 unused shared
  libraries, one reference to the private library `libflutter_linux_gtk.so`,
  "dependency may not be needed" hints for the dlopen- and exec-based entries, and
  two PKGBUILD hints about `x86_64` versus `$CARCH`.
- `desktop-file-validate` warns that the vendor desktop entry repeats
  `GenericName` in `Comment`; this is a non-fatal cosmetic upstream issue.
- Not tested: host installation and removal (`test-install.sh` was not run), GUI
  startup, a real unattended connection, DRM capture on a Wayland compositor,
  PipeWire/portal fallback, the systemd service running as root, and any
  firewall, port-forward or relay configuration. Remote CI has not run for this
  package.

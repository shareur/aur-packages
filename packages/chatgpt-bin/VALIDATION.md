# Validation: chatgpt-bin 26.1029.61003-1

- Upstream: OpenAI's APT repository
  `https://persistent.oaistatic.com/codex-app-prod/linux/deb`, package `chatgpt`
  26.1029.61003 amd64, homepage https://developers.openai.com/codex/app.
- The recipe pins the pool path
  `pool/main/c/chatgpt/chatgpt_26.1029.61003_amd64.deb`. The vendor also serves a
  floating `/latest/chatgpt_amd64.deb` alias with the same content. SHA256 agrees in
  three places: the local file, a fresh download of the pinned URL (558314862 bytes)
  and the `SHA256:` field of `dists/stable/main/binary-amd64/Packages` —
  `f3af8afec5d25c228eb6f4dbd9cfde0fea7ca5e4b42aff0145a1ded273d01b2d`.
- DEB control: `Installed-Size: 1797560` (KiB), `Recommends: git`, conffile
  `/etc/apparmor.d/chatgpt`. The Debian dependency list covers the Chromium stack,
  TPM2, libusb, ALSA, CUPS, xdg-utils, xz-utils and a Vulkan ICD.
- Maintainer scripts were read, not executed. `postinst` writes
  `/etc/apt/sources.list.d/chatgpt.sources`, an APT keyring and
  `/etc/default/chatgpt`, runs `update-desktop-database` and (re)loads the shipped
  AppArmor profile; `prerm` unloads that profile; `postrm purge` deletes the APT
  files. None of this runs under pacman; see the package README for the reasoning.
- ELF inspection: `ChatGPT` links alsa, atk, atk-bridge, atspi, cairo, cups, dbus,
  expat, gbm, gdk-pixbuf, gio/glib/gobject, gtk-3, nspr4, nss3, nssutil3, smime3,
  pango, udev, X11, xcb, Xcomposite, Xdamage, Xext, Xfixes, xkbcommon and Xrandr,
  and has no RUNPATH. `resources/codex`, `resources/codex-code-mode-host` and
  `resources/tectonic/tectonic` are static PIE; the bundled Node runtime needs only
  glibc and gcc-libs; Chromium ships its own libEGL, libGLESv2, libvk_swiftshader
  and libvulkan.so.1.
- Runtime-opened libraries add: `libnotify.so.4`, `libpulse`, `libpipewire-0.3`,
  `libEGL`/`libGLESv2`/`libGL` (libglvnd), `libvulkan` (vulkan-icd-loader),
  `libxcb-dri3`/`glx`/`present`/`sync` (libxcb), `libX11-xcb`, and
  `libGLX_nvidia.so.0` (nvidia-utils, optdepend). The native module
  `resources/native/remote-control-device-key.node` needs `libtss2-mu`,
  `libtss2-esys` and `libtss2-tcti-device` (tpm2-tss), and the Work Louder device-kit
  modules need `libusb-1.0.so.0` (libusb). `mesa` supplies `libgbm.so.1`.
- `xz` and `xdg-utils` are declared because the Codex agent shells out to xz and the
  client calls `xdg-open`. `libssl3` from the Debian list is not declared: BoringSSL
  is linked statically and no `libssl`/`libcrypto` reference exists in the payload.
- Python is an optdepend, not a dependency: many bundled scripts carry
  `#!/usr/bin/env python3` shebangs and the Codex agent can run Python code, but the
  vendor DEB does not declare Python and the client starts without it.
- Sandbox: the payload contains no setuid helper and no `chrome-sandbox`; the
  launcher only forwards its arguments to `/usr/lib/chatgpt/ChatGPT`.
- `ChatGPT --version` prints `26.1029.61003`, exits 0, needs no display and writes
  nothing to `$HOME`.
- Local `makepkg --force --noconfirm` build succeeded with every declared dependency
  installed on the host (no `--nodeps`): package archive about 646 MB, installed size
  1838897633 bytes (archive bytes vary slightly between rebuilds because the tar
  timestamps change). `.SRCINFO` consistency, the package-specific layout checks
  (desktop syntax, launcher symlink target, required payload paths, absence of
  `/usr/share/doc` and `/usr/share/lintian`, unmodified launcher content, no setuid
  payload) and `desktop-file-validate` all passed; the only desktop hint is that
  `Categories` lists two main categories.
- namcap accepts exactly seven diagnostics for this package, each reviewed:
  `lib32-gcc-libs`, `lib32-glibc` and `lib32-systemd` are reported by ARM/32-bit
  `.node` prebuilds shipped for other platforms; `java-runtime` comes from a `.jar`
  data file inside a device-tool module; `nodejs` comes from `#!/usr/bin/env node`
  scripts that run on the bundled Node runtime; `python-numpy` and `python-pillow`
  come from optional imports inside bundled Python helpers and skills.
- The remaining 203 namcap warnings are recorded, not suppressed: 23 missing FULL
  RELRO, 28 non-PIE, 12 unstripped, 55 unused shared libraries, 55 references to the
  bundled `pyproto` Python modules, 16 references to bundled private libraries,
  `python` and `qt6-base` detected-but-optional, and "may not be needed" hints for
  the runtime-spawned `xz`, `xdg-utils` and `vulkan-icd-loader`.
- Not tested: host installation and removal (`test-install.sh` was not run), GUI
  startup, sign-in, model access, Codex task execution, sandbox enforcement, Wayland
  or X11 rendering, the AppArmor profile being loaded, and remote CI.

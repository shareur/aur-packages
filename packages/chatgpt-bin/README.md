# chatgpt-bin

Official **ChatGPT desktop app** (OpenAI "Codex app") Linux build, repackaged for
Arch Linux / CachyOS x86_64. Maintainer: **Yang <shareur@imyang.me>**.
Recipe version: **26.1029.61003-1**.

[简体中文](../../docs/zh-cn/packages/chatgpt-bin/README.md)

## What this package is

OpenAI publishes the desktop app as an APT repository with a `chatgpt` DEB. The
application is an Electron/Chromium bundle: `usr/lib/chatgpt/ChatGPT` is the browser
process, `resources/app.asar` holds the UI, and `resources/codex` is the statically
linked Rust agent that runs Codex tasks locally. Nothing is compiled here; the
vendor payload is repackaged unchanged except for Debian-only metadata (see below).

The installed payload is large: about **1.8 GB** on disk, because the bundle ships
its own Chromium, Node runtime, Codex binary and TeX engine.

## Install

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/chatgpt-bin
makepkg -si
chatgpt
```

Run `makepkg` as a regular user. The recipe downloads the pinned DEB from OpenAI's
package pool and verifies SHA256. Update by pulling the repository and running
`makepkg -si` again; remove with `sudo pacman -R chatgpt-bin`. Application data and
logins live in the user's home directory and are not touched.

## Differences from the vendor DEB

The Debian maintainer scripts are inspected but **never executed**, so the
following vendor behaviour is intentionally absent:

- **No APT repository is configured.** `postinst` normally writes
  `/etc/apt/sources.list.d/chatgpt.sources`, an APT keyring and
  `/etc/default/chatgpt` so that the app updates through `apt`. On Arch that would
  add a foreign update channel that pacman knows nothing about, so updates come
  only from this recipe. Expect pacman to be the single source of updates.
- **No automatic desktop-database or AppArmor actions.** Arch applies desktop,
  icon and AppStream caches through pacman hooks.
- **No AppArmor profile is loaded.** The vendor file `etc/apparmor.d/chatgpt` is
  shipped as a configuration file (listed in `backup`), so it stays inert unless
  AppArmor is enabled on this host. It only grants unprivileged user namespaces to
  `/usr/lib/chatgpt/ChatGPT`, which matters on distributions that restrict them;
  Arch allows them by default, so the profile is normally unnecessary.

Two Debian paths are also dropped: `usr/share/doc/chatgpt/copyright` is installed as
`/usr/share/licenses/chatgpt-bin/copyright`, and the one-byte lintian override under
`/usr/share/lintian/` is not shipped. Everything else, including the
`/usr/bin/chatgpt` → `../lib/chatgpt/codex-launcher` symlink and the vendor desktop
entry, is kept as published.

## Sandboxing

The bundle contains no setuid `chrome-sandbox` helper, so the Chromium sandbox uses
user namespaces. Do not add `--no-sandbox`: the launcher runs
`/usr/lib/chatgpt/ChatGPT` with the arguments it is given and nothing else.

The vendor desktop entry registers `x-scheme-handler/codex` plus `http`, `https` and
several office MIME types. It becomes a *candidate* handler for those links, not the
default; change that in your desktop settings if you do not want it.

## Dependencies

Declared dependencies come from ELF inspection of the shipped binaries plus the
libraries the Chromium runtime opens at runtime (`libnotify`, `libpulse`,
`libpipewire`, `libglvnd`, `vulkan-icd-loader`). `mesa` is required because it
provides `libgbm.so.1`; `xz` is required because the Codex agent shells out to it.
Optional pieces: `git` for Codex version-control features, and the Qt 5/6 shims
that Chromium uses for native file dialogs. NVIDIA's proprietary GLX/Vulkan driver
is optional and only used when installed.

## Verification and limits

From the repository root:

```bash
bash scripts/validate.sh chatgpt-bin
# Interactive sudo; installs, checks and removes the package, then restores it.
bash scripts/test-local-install.sh chatgpt-bin
```

`chatgpt --version` prints `26.1029.61003` and exits without opening a window, which
is the smoke check used locally and in CI. Validation covers the source checksum,
build, `.SRCINFO` consistency, namcap, desktop-file syntax, the launcher/target
layout, the absence of Debian metadata, and the absence of setuid payloads.

Not covered: an installed GUI session, sign-in, model access, Codex task execution,
sandbox behaviour, Wayland/X11 rendering and the AppArmor profile actually being
loaded. A successful build and version command are not evidence for any of them.

## Licensing

The application is proprietary (upstream AppStream metadata declares
`LicenseRef-proprietary`), so this package is declared the same way. The vendor
`copyright` file, which covers Electron and bundled components, is installed to
`/usr/share/licenses/chatgpt-bin/copyright`, and Chromium's component licenses stay
in `/usr/lib/chatgpt/LICENSES.chromium.html`. This repository only maintains
recipes; it does not host the DEB or built binary packages, and its own MIT license
does not relicense ChatGPT or the bundled components.

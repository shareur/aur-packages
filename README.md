# aur-packages

[![Validate](https://github.com/shareur/aur-packages/actions/workflows/validate.yml/badge.svg?branch=master)](https://github.com/shareur/aur-packages/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Arch Linux / CachyOS packaging recipes maintained by **Yang** (<shareur@imyang.me>) in [shareur/aur-packages](https://github.com/shareur/aur-packages).

[简体中文](docs/zh-cn/README.md)

## Contents

- [What this repository is](#what-this-repository-is)
- [Packages](#packages)
- [Requirements](#requirements)
- [Install](#install)
- [Maintain and validate](#maintain-and-validate)
- [Continuous integration](#continuous-integration)
- [Repository layout](#repository-layout)
- [Contributing, security, and license](#contributing-security-and-license)
- [Support](#support)
- [Future AUR publication](#future-aur-publication)

## What this repository is

This repository contains Arch Linux and CachyOS packaging recipes, shared helper scripts, and documentation. It is a packaging project, not a fork of the packaged applications.

- It hosts recipes and documentation only. It does not host DEBs, built packages, or downloaded sources.
- Upstream applications keep their own licenses and their own issue trackers. Report application bugs upstream; report recipe problems here.
- Repository-authored recipes, scripts, and documentation are licensed under MIT. Third-party applications and bundled components keep their own licenses.
- GitHub `master` is the source of truth. AUR publication is currently disabled; see [Future AUR publication](#future-aur-publication).

## Packages

| Package | Version | What it is | CI |
| --- | --- | --- | --- |
| [115life-desktop-bin](packages/115life-desktop-bin/) | 37.3.2-3 | 115 Life desktop client (binary release) | build, install/remove, Xvfb window |
| [115life-browser-bin](packages/115life-browser-bin/) | 36.0.1-1 | 115 browser, Chromium based (binary release) | build, install/remove, version |
| [rustdesk-unattended-wayland](packages/rustdesk-unattended-wayland/) | 1.5.1-1 | RustDesk client for unattended access on Wayland (binary release) | build, install/remove, version |
| [chatgpt-bin](packages/chatgpt-bin/) | 26.1029.61003-1 | OpenAI ChatGPT desktop app (binary release) | build, install/remove, version |
| [fcitx5-windinput-git](packages/fcitx5-windinput-git/) | 0.130.1.r41.gc70da4c-1 | WindInput (清风输入法) Fcitx5 input method, built from source | build, install/remove |

Each package has its own guide with dependencies, limitations, and verification status. Historical test notes are in each package `VALIDATION.md`. CI results are on the Actions page.

## Requirements

- Arch Linux or CachyOS, `x86_64`.
- `base-devel` (includes `makepkg`), `namcap`, `desktop-file-utils`, and `shellcheck` for validation.
- Source-built packages need their declared build dependencies; `makepkg --syncdeps` resolves them.

## Install

```bash
sudo pacman -S --needed base-devel namcap desktop-file-utils shellcheck
git clone https://github.com/shareur/aur-packages.git
cd aur-packages/packages/fcitx5-windinput-git
makepkg -si
```

Review the PKGBUILD before building, and run `makepkg` as a regular user. Sources are downloaded from upstream and verified with pinned checksums unless a VCS source is documented. No vendor DEB or built package is hosted here.

To update, run `git pull --ff-only` and `makepkg -si` again in the package directory. To remove, run `sudo pacman -R <pkgname>`; user configuration and downloaded files are kept.

## Maintain and validate

Recipes and supporting files belong in `packages/<pkgbase>/`; shared tooling is in `scripts/`; workflows are in `.github/workflows/`.

```bash
# From the repository root; omit the package argument to validate all packages.
bash scripts/validate.sh <pkgbase>
shellcheck scripts/*.sh
# Close the client first: installs/removes/restores the host package using sudo.
bash scripts/test-local-install.sh <pkgbase>
```

`scripts/validate.sh` verifies sources, builds the package, regenerates and compares `.SRCINFO`, runs `namcap`, runs the optional `check-package.sh`, and records a manifest and SHA256. It applies two conventions:

- For VCS packages (a PKGBUILD that defines `pkgver()`), the `.SRCINFO` comparison ignores the `pkgver` line, because that value moves with upstream; all other metadata is still compared strictly.
- Packages named `*-debug` that `makepkg` generates under the `debug` option are excluded from lint and package checks, because their `/usr/lib/debug/.build-id` symlinks point into the main package. The source-built WindInput recipe also disables `debug` and `lto` explicitly.

Regenerate `.SRCINFO` after any PKGBUILD change, and validate before committing. Logs are written to `reports/<pkgbase>/`, which is ignored.

## Continuous integration

`validate.yml` selects the packages changed by a push or pull request and builds each one in a disposable `archlinux:base-devel` container: it installs the package, checks it, removes it, and uploads reports only. Changes under `scripts/` or `.github/workflows/` validate all packages. `upstream.yml` is a manual version check for one upstream and never edits recipes or publishes. A green run does not replace interactive desktop testing; each package guide states what was not verified.

## Repository layout

    packages/<pkgbase>/     recipe, .SRCINFO, guide, VALIDATION.md, optional checks
    scripts/                shared validation, CI, and publishing helpers
    .github/workflows/      CI workflows
    docs/                   project documentation and publishing plan
    docs/zh-cn/             Chinese documentation, same relative paths

## Contributing, security, and license

- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Security policy and private reporting: [SECURITY.md](SECURITY.md)
- Code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- License: [LICENSE](LICENSE) (MIT for repository-authored files; third-party applications keep their own licenses)
- Chinese versions: [docs/zh-cn/](docs/zh-cn/)

## Support

- Recipe problems, build failures, and documentation issues: open an issue in this repository.
- Security reports: email the maintainer privately, as described in [SECURITY.md](SECURITY.md).
- Application bugs and feature requests: contact the upstream project. This repository only packages it.

## Future AUR publication

AUR publication is currently disabled because the maintainer cannot yet register an AUR account. After registration, each pkgbase will use its own AUR repository. The manual helper defaults to a read-only preview; `--push` commits and publishes and requires explicit authorization. See [the publishing plan](docs/automation.md); the `.disabled` workflow examples are historical references and are not ready to enable.

## Naming

`115life-desktop-bin` is the Life desktop client; `115life-browser-bin` is the separate Chromium-based browser recipe; `rustdesk-unattended-wayland` is the RustDesk Wayland build for unattended access; `chatgpt-bin` is the OpenAI ChatGPT desktop app; `fcitx5-windinput-git` is the WindInput Fcitx5 input method built from source.

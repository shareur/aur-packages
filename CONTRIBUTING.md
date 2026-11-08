# Contributing

Thanks for your interest in improving these packaging recipes. This guide explains how to report problems, propose changes, and get a pull request merged.

## Ways to contribute

- Report a bug: open an issue with the package name and the details listed in the issue template.
- Report a security issue: see SECURITY.md and email the maintainer instead of opening a public issue.
- Improve a package: fix a recipe, update an upstream version, or add a new recipe.
- Improve tooling or documentation: scripts, workflows, README, and package guides.

## Ground rules

- Upstream first. Recipes should follow the official Arch packaging guidelines and use the upstream project as the source of truth.
- No binaries. Do not commit DEB files, built packages, build directories, or downloaded sources. They are ignored and must not be added.
- No secrets. Never commit credentials, tokens, private keys, or personal data.
- Keep changes focused: one concern per pull request, and keep unrelated packages out unless required.
- Contributions are accepted under the repository license (MIT) for repository-authored files. Third-party software keeps its own license.

## Development setup

You need an Arch Linux or CachyOS host, or a disposable Arch container.

    sudo pacman -S --needed base-devel namcap desktop-file-utils shellcheck

Clone the repository and work on a branch:

    git clone https://github.com/shareur/aur-packages.git
    cd aur-packages
    git switch -c my-change

## Package layout

Each recipe lives in its own directory:

    packages/<pkgbase>/
      PKGBUILD            recipe
      .SRCINFO            generated metadata, committed
      README.md           user-facing guide (English)
      VALIDATION.md       what was tested, and what was not
      check-package.sh    optional package-specific checks
      test-install.sh     optional host install/remove check
      download.link       upstream download or repository URL
      .aur-files          optional list of extra files for AUR

Chinese documentation for a package belongs in `docs/zh-cn/packages/<pkgbase>/`.

## Making a change

1. For version updates, change `pkgver`/`pkgrel`, update checksums, and verify them against a fresh download.
2. Regenerate metadata after any PKGBUILD change:

       makepkg --printsrcinfo > .SRCINFO

3. Update the package README and VALIDATION.md to describe what changed and what was actually tested. Do not describe untested behavior as verified.
4. If the change affects shared behavior, update the matching Chinese document in `docs/zh-cn/` with the same relative path.

## Validation

Run the checks that are relevant to the change, from the repository root:

    bash scripts/validate.sh <pkgbase>   # sources, build, metadata, namcap, package checks
    shellcheck scripts/*.sh              # when editing shared shell scripts

`scripts/validate.sh` writes logs to `reports/<pkgbase>/`. Installing the package on the host changes the system; run it only with explicit intent:

    bash scripts/test-local-install.sh <pkgbase>

Never run `scripts/ci-build.sh` on the host; it is meant for disposable containers.

## Commit messages

Use a short imperative subject that names the package or area, for example:

    fcitx5-windinput-git: disable makepkg debug package

Keep unrelated changes in separate commits. Do not rewrite published history.

## Pull requests

A pull request should:

- touch one package or one concern;
- include PKGBUILD and .SRCINFO that match each other;
- explain what was tested and what was not tested;
- not include binaries, build outputs, secrets, or unrelated files.

CI builds changed packages in a disposable Arch container, then checks installation and removal. Reports are uploaded as artifacts. A green CI run is not a substitute for interactive desktop testing; state clearly in the pull request what you could not verify.

## License

By contributing, you agree that repository-authored content is licensed under the MIT license in LICENSE, and that you have the right to submit it.

## Validation conventions

- For VCS (`-git`) packages the `.SRCINFO` comparison ignores the `pkgver` line, because that value moves with upstream; all other metadata is still compared strictly.
- Packages named `*-debug` that `makepkg` generates under the `debug` option are excluded from lint and package checks; their `/usr/lib/debug/.build-id` symlinks point into the main package.

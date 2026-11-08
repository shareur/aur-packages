# Security Policy

## Scope

This repository contains packaging recipes, helper scripts, and documentation for Arch Linux / CachyOS packages. It does not host the packaged applications. Security issues in an upstream application should be reported to that project; the recipe will be updated once an upstream fix is available.

Issues that are in scope here include, for example:

- a recipe that downloads and installs tampered or unverified content;
- a checksum mismatch, or a source that is not pinned as documented;
- a helper script (validate, ci-build, test-local-install, publish) that could run unexpected commands, leak credentials, or modify the host unexpectedly;
- accidental inclusion of secrets or private data in the repository.

## Reporting a vulnerability

Please report suspected vulnerabilities privately by email to:

- shareur@imyang.me

Do not open a public issue for a sensitive report. Include the affected package or script, the commit or version, reproduction steps, and the impact you expect. If you can, include a minimal proof of concept.

## What to expect

- We aim to acknowledge a report within a few days.
- We will confirm the issue, agree on a fix, and credit you if you wish.
- Fixes are published in this repository. Recipes may be re-published to AUR after review; publishing is manual and requires explicit approval.

## Supported versions

Only the current `master` branch is maintained. Recipes track upstream releases, so use the latest commit and the upstream version listed in each package directory.

## Repository hygiene

- Secrets, tokens, private keys, and personal data must never be committed.
- Sources are verified with pinned checksums where possible.
- CI validates changed packages in a disposable container and uploads reports only.

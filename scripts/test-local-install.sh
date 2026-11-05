#!/usr/bin/env bash
# Interactive sudo only; never put passwords in arguments or environment variables.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
package=${1:?Usage: test-local-install.sh PACKAGE}
[[ $package =~ ^[a-z0-9][a-z0-9+_.-]*$ ]] || exit 2
cd "$root/packages/$package"
[[ -f test-install.sh ]] || { echo 'No lifecycle check for this package' >&2; exit 1; }
bash test-install.sh

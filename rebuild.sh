#!/usr/bin/env bash

# Change into script dir.
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null || exit
nixosDir=$(pwd)

# Get short hostname to work with host specific configurations.
host=$(hostname -s)
if [[ -n $nixHostOverride ]]; then
    host=$nixHostOverride
fi

# Confirm host configuration is available; If not, we should not continue.
if ! grep -q "nixosConfigurations.$host" flake.nix; then
    host="default"
fi

# Rebuild and switch.
# shellcheck disable=SC2068
nixos-rebuild switch --impure --flake "path:$nixosDir/#$host" $@

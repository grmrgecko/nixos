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
if ! grep -q "nixosConfigurations.$host " flake.nix; then
    host="default"
fi

# Install NixOS.
# shellcheck disable=SC2068
nix --extra-experimental-features 'nix-command flakes' run 'github:nix-community/disko#disko-install' -- --flake "path:$nixosDir/#$host" $@

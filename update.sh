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

# Update nixpkgs.
if ! sudo -u grmrgecko nix flake update "$nixosDir"; then
    echo "Update failed"
    exit 1
fi

# Add updated lock file to git staging for rebuild below.
sudo -u grmrgecko git add flake.lock

# Commit update.
sudo -u grmrgecko git commit -m "Flake update $(date)"

# Rebuild and switch.
# shellcheck disable=SC2068
nixos-rebuild switch --impure --flake "path:$nixosDir/#$host" $@

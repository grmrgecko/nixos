#!/usr/bin/env bash

# Change into script dir.
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null || exit
nixosDir=$(pwd)

# Get short hostname to work with host specific configurations.
host=$(hostname -s)
if [[ -n $nixHostOverride ]]; then
    host=$nixHostOverride
fi

if (( EUID==0 )); then
    sudoCmd="sudo -u grmrgecko"
fi

# Confirm host configuration is available; If not, we should not continue.
if ! grep -q "nixosConfigurations.$host " flake.nix; then
    host="default"
fi

# Update nixpkgs.
if ! $sudoCmd nix flake update; then
    echo "Update failed"
    exit 1
fi

# Add updated lock file to git staging for rebuild below.
$sudoCmd git add flake.lock

# Commit update.
$sudoCmd git commit -m "Flake update $(date)"

# Rebuild and switch.
# shellcheck disable=SC2068
sudo nixos-rebuild switch --impure --flake "path:$nixosDir/#$host" $@

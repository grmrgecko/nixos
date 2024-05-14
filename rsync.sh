#!/usr/bin/env bash

# Change into script dir.
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null || exit
nixosDir=$(pwd)

# Sync configuration via rsync.
rsync -av --delete --exclude settings.nix --exclude hardware-configuration.nix "$nixosDir/" "$1:nixos/"
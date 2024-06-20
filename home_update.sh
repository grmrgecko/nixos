#!/usr/bin/env bash

# Change into script dir.
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null || exit
nixosDir=$(pwd)

# Rebuild and switch.
# shellcheck disable=SC2068
home-manager switch --flake "path:$nixosDir" $@

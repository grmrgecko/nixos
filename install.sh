#!/usr/bin/env bash

# Change into script dir.
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null || exit
nixosDir=$(pwd)

remoteAddr=""
echo -n "Install on [local machine]: "
read -r CHOICE
if [[ -n $CHOICE ]]; then
    remoteAddr="$CHOICE"
fi
sshCmd=""
if [[ -n $remoteAddr ]]; then
    if ssh "$remoteAddr" /usr/bin/env true; then
        sshCmd="ssh $remoteAddr"
    else
        echo "Unable to confirm connection to remote $remoteAddr"
    fi
fi

# Get short hostname to work with host specific configurations.
host=""
if [[ "$(grep hostName settings.nix)" =~ \"(.*)\" ]]; then
    host=${BASH_REMATCH[1]}
fi

# If hostname wasn't found, try using the hostname command.
if [[ -z $host ]]; then
    host=$($sshCmd hostname -s)
fi

# Confirm host configuration is available; If not, we should not continue.
if ! grep -q "nixosConfigurations.$host " flake.nix; then
    host="default"
fi

# If remote address provided, use nixos-anywhere.
if [[ -n $remoteAddr ]]; then
    localArch=$(uname -m)
    remoteArch=$($sshCmd uname -m)
    if [[ "$localArch" != "$remoteArch" ]]; then
        # shellcheck disable=SC2068
        nix --extra-experimental-features 'nix-command flakes' run 'github:nix-community/nixos-anywhere' -- --build-on-remote --flake "path:$nixosDir/#$host" "$remoteAddr"  $@
    else
        # shellcheck disable=SC2068
        nix --extra-experimental-features 'nix-command flakes' run 'github:nix-community/nixos-anywhere' -- --flake "path:$nixosDir/#$host" "$remoteAddr"  $@
    fi
else
    # Otherwise install with disko-install.
    # shellcheck disable=SC2068
    nix --extra-experimental-features 'nix-command flakes' run 'github:nix-community/disko#disko-install' -- --flake "path:$nixosDir/#$host" $@
fi

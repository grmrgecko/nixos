#!/usr/bin/env bash

# Change into script dir.
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null || exit
nixosDir=$(pwd)


# Print the help for this command.
print_help() {
    echo "NixOS Rsync"
    echo
    echo "Usage:"
    echo "$0 [--help|--include-settings] {host}"
    exit
}

# Defaults
remoteAddr=""
excludes="--exclude settings.nix --exclude hardware-configuration.nix"

# Parse provided arguments.
while (( $# > 0 )); do
    case "$1" in
        -h|h|help|--help)
            print_help "$@"
        ;;
        -i|--include-settings)
            excludes=""
            shift
        ;;
        *)
            remoteAddr="$1"
            shift
        ;;
    esac
done

# If no address provided, exit.
if [[ -z $remoteAddr ]]; then
    echo "You must provide a host."
    echo
    print_help "$@"
fi

# Sync configuration via rsync.
eval rsync -av --delete "$excludes" "'$nixosDir/'" "'$remoteAddr:nixos/'"

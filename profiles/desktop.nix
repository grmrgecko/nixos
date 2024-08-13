{ config, lib, pkgs, settings, ... }:

{
  # Import modules.
  imports = [
    ../modules/nixos/common.nix
    ../modules/nixos/network.nix
    ../modules/nixos/users.nix
    ../modules/nixos/management.nix
    ../modules/nixos/desktop.nix
    ../modules/nixos/docker.nix
    ../modules/nixos/mnt-merged.nix
  ];
}

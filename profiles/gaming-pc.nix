{ config, lib, pkgs, settings, ... }:

{
  # Import modules.
  imports = [
    ./desktop.nix
    ../modules/nixos/gaming.nix
  ];
}

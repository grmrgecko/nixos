# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, settings, ... }:

{
  # Enable flakes for package pinning.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Import modules.
  imports = [
    ../../hardware-configuration.nix
    ../../profiles/${settings.profile}.nix
  ];

  # Do not change the following.
  system.stateVersion = "23.11";
}

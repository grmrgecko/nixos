{ config, lib, pkgs, settings, ... }:

{ 
  # Import modules.
  imports = [
    ../modules/nixos/common.nix
    ../modules/nixos/network.nix
    ../modules/nixos/users.nix
    ../modules/nixos/management.nix
    ../modules/nixos/monitoring.nix
    ../modules/nixos/virtualization.nix
  ];

  # Allow unsupported SPF+ modules.
  boot.kernelParams = [
    "ixgbe.allow_unsupported_sfp=1"
  ];
}

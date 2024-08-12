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
    ../../modules/nixos/zfs.nix
  ];

  # Fix AMD SATA bug?
  boot.kernelParams = [
    "iommu=soft"
  ];

  # Enable NFS export for kvm storage.
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/kvm        10.0.100.5(rw,async,no_subtree_check,no_root_squash,fsid=1) 10.0.100.7(rw,async,no_subtree_check,no_root_squash,fsid=1) 10.0.100.8(rw,async,no_subtree_check,no_root_squash,fsid=1) 10.0.100.13(rw,async,no_subtree_check,no_root_squash,fsid=1)
  '';

  # Do not change the following.
  system.stateVersion = "23.11";
}

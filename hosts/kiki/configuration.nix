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
  boot.initrd.kernelModules = [
    "mpt3sas"
  ];

  # Enable NFS export for kvm storage.
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/merged 10.0.0.19(ro,sync,fsid=1) 10.0.0.15(rw,sync,no_subtree_check,no_root_squash,fsid=1) 10.0.0.14(rw,sync,fsid=1) 10.0.0.13(rw,sync,fsid=1) 10.0.0.10(rw,sync,fsid=1,insecure) 10.0.0.1(rw,sync,fsid=1) 10.0.0.35(rw,sync,fsid=1) 10.9.0.2(rw,sync,fsid=1) 10.0.0.219(rw,sync,fsid=1)
  '';

  # Do not change the following.
  system.stateVersion = "23.11";
}

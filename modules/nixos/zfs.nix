{ config, lib, pkgs, ... }:

{
  boot.supportedFilesystems = [ "zfs" ];

  # Set kernel to latest compatible version with ZFS.
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  environment.systemPackages = with pkgs; [
    zfs
  ];

  services.zfs.autoScrub.enable = true;
}

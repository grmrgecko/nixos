{ config, lib, pkgs, settings, ... }:

{
  # Install Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.daemon.settings.features.cdi = true;
  users.users.${settings.user.name}.extraGroups = [ "docker" ];

  # Distrobox
  environment.systemPackages = with pkgs; [
    distrobox
  ];
}

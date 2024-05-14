{ config, lib, pkgs, settings, ... }:

{
  # Enable the Desktop Environment.
  services.xserver.desktopManager.plasma5.enable = false;
  services.desktopManager.plasma6.enable = true;
}

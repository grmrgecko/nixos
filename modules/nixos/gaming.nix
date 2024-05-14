{ config, lib, pkgs, settings, ... }:

{
  # Enable steam for gamming.
  programs.steam.enable = true;

  # Gui applications for the main user.
  users.users.${settings.user.name}.packages = with pkgs; [
      lutris
  ];
}

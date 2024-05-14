{ config, lib, pkgs, settings, ... }:

{
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };

  # Extra global packages for guis.
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland
  ];
}

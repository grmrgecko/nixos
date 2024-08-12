{ config, lib, pkgs, settings, ... }:

{
  # Display drivers.
  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = [ "qxl" ];
  # services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}

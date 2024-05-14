{ config, lib, pkgs, settings, ... }:

{
  # Display drivers.
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = [ "qxl" ];
  # services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}

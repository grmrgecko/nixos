{ config, lib, pkgs, settings, ... }:

{
  # Display drivers.
  hardware.graphics = {
    enable = true;
  };
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
}

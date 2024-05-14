{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cockpit
  ];

  services.cockpit = {
    enable = true;
    port = 9090;
    settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "without-password";
}

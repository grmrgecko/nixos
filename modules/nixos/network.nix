{ config, lib, pkgs, settings, ... }:

{
  # Network host configuration.
  networking.hostId = settings.hostId;
  networking.hostName = settings.hostName;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    dnsutils
    iperf
    nmap
    netcat-gnu
  ];
}

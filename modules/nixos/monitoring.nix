{ config, lib, pkgs, ... }:

{
  users.groups.telegraf = {};
  users.users.telegraf = {
    isNormalUser = false;
    isSystemUser = true;
    group = "telegraf";
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    telegraf
    smartmontools
    nvme-cli
    lm_sensors
  ];

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "${pkgs.smartmontools}/bin/smartctl";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nvme-cli}/bin/nvme";
          options = [ "NOPASSWD" ];
        }
      ];
      users = [ "telegraf" ];
    }];
  };

  systemd.services.telegraf = {
    enable = true;
    description = "Telegraf";
    after = [ "network.target" ];
    path = [
      "/run/wrappers"
      pkgs.lm_sensors
      pkgs.smartmontools
      pkgs.nvme-cli
    ];
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
      User = "telegraf";
      ExecStart = "${pkgs.telegraf}/bin/telegraf -config /etc/telegraf/telegraf.conf -config-directory /etc/telegraf/telegraf.d";
      ExecReload = "/bin/kill -HUP $MAINPID";
      Restart = "on-failure";
      RestartForceExitStatus = "SIGPIPE";
      KillMode = "mixed";
      TimeoutStopSec = "5";
      LimitMEMLOCK = "8M:8M";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

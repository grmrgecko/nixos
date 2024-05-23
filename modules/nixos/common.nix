{ config, lib, pkgs, settings, ... }:

{
  # Import modules.
  imports = [
    (import (if (settings.disk.luks)
        then
          ./disko-luks.nix
        else
          ./disko.nix
      ) {
      device = settings.disk.device;
      swapSize = settings.disk.swapSize;
    })
  ] ++ (if settings.videoDrivers=="unknown" then [] else [ ./video-drivers/${settings.videoDrivers}.nix ]);

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];

  # BTRFS Scrubbing Services.
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "weekly";

  # Set your time zone.
  time.timeZone = settings.timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = settings.locale;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  users.groups.mlocate = {};
  environment.systemPackages = with pkgs; [
    # Text Editors
    vim
    nano
    
    # Network
    wget
    curl
    git
    rsync
    borgbackup

    # Disk Tools
    btrfs-progs
    nfs-utils
    parted
    ncdu
    pv

    # System Tools
    sudo
    cron
    mlocate
    tmux
    screen
    picocom
    killall
    pciutils

    # Performance monitor
    nmon
    iotop
    htop
  ];

  # Compatibility with scripts.
  system.activationScripts.binbash = {
    text =
    ''
      ln -sfn /run/current-system/sw/bin/bash /bin/bash
    '';
  };

  # Nix Package Auto Cleanup
  nix = {
    settings.auto-optimise-store = true;
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-oder-than 7d";
    };
  };
}

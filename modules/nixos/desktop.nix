{ config, lib, pkgs, settings, ... }:

{
  # Import desktop environments.
  imports = [
    ./desktop-environments/plasma.nix
    ./desktop-environments/hyperland.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Display Manager.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = settings.user.autoLogin;
  services.displayManager.autoLogin.user = if settings.user.autoLogin then settings.user.name else "";

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable Flatpak
  services.flatpak.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Gui applications for the main user.
  users.users.${settings.user.name}.packages = with pkgs; [
    # Internet
    thunderbird
    ungoogled-chromium

    # Remote management
    remmina
    transmission-remote-gtk
    virt-manager

    # Development
    kdePackages.kate

    # Multimedia
    clementine
    mpv
    vlc
    kdePackages.k3b

    # Desktop
    polybar
    appimage-run

    # Software defined radio
    gqrx
  ] ++ (if settings.system=="x86_64-linux" then [ arduino-ide ] else []);

  # Kodi
  services.xserver.desktopManager.kodi.enable = true;
  services.xserver.desktopManager.kodi.package = pkgs.kodi.withPackages (pkgs: with pkgs; [
    # osmc-skin
    jellyfin
    pvr-hdhomerun
    pvr-iptvsimple
  ]);

  # Extra global packages for guis.
  environment.systemPackages = with pkgs; [
    xdg-utils
    xdg-desktop-portal
  ];
}

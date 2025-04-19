{ inputs, config, lib, pkgs, settings, ... }:

{
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    user = settings.user.name;
    dataDir = "/home/${settings.user.name}";
  };

  # Enable ZSH.
  programs.zsh.enable = true;

  # Rebuild users.
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.${settings.user.name}.gid = 1000;
  users.users.${settings.user.name} = {
    isNormalUser = true;
    description = settings.user.description;
    extraGroups = [ "networkmanager" "wheel" ];
    uid = 1000;
    group = settings.user.name;
    shell = pkgs.zsh;
    hashedPassword = settings.user.hashedPassword;
    openssh.authorizedKeys.keys = settings.user.openssh.authorizedKeys.keys;
  };
  users.users.root = {
    shell = pkgs.zsh;
    hashedPassword = settings.root.hashedPassword;
    openssh.authorizedKeys.keys = settings.root.openssh.authorizedKeys.keys;
  };

  environment.systemPackages = with pkgs; [
    nodejs_23
    pure-prompt
    fastfetch
    home-manager
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit settings;
    };
    users = {
      ${settings.user.name} = {
        imports = [
          inputs.flatpaks.homeManagerModules.default
          ../../users/main-user.nix
        ];
      };
      "root" = import ../../users/root.nix;
    };
  };
}

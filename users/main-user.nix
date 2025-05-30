{pkgs, settings, ...}:

{
  imports = [
    ../modules/home/git.nix
    ../modules/home/zsh.nix
  ] ++ (if (builtins.pathExists ../modules/home/profiles/${settings.profile}.nix)
            then
              [ ../modules/home/profiles/${settings.profile}.nix ]
            else
              []
            );

  home.username = settings.user.name;
  home.homeDirectory = "/home/${settings.user.name}";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}

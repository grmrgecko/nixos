{pkgs, settings, ...}:

{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
  };
}
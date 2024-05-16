{pkgs, settings, ...}:

{
  home.file = {
    ".config/mpv".source = ../../../dotfiles/.config/mpv;
    ".config/polybar".source = ../../../dotfiles/.config/polybar;
  };
}
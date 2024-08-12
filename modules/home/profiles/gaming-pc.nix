{pkgs, settings, ...}:

{
  imports = [
    ./desktop.nix
  ];
  services.flatpak.packages = [
    "flathub:app/org.kde.kdenlive/x86_64/stable"
    "flathub:app/org.mozilla.Thunderbird/x86_64/stable"
    "flathub:app/com.calibre_ebook.calibre/x86_64/stable"
    "flathub:app/org.blender.Blender/x86_64/stable"
  ];
}
{pkgs, settings, ...}:

{
  # Setup flatpaks.
  services.flatpak.enableModule = true;
  services.flatpak.remotes = {
    "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  };
  services.flatpak.packages = [
    "flathub:app/org.libreoffice.LibreOffice/x86_64/stable"
    "flathub:app/org.onlyoffice.desktopeditors/x86_64/stable"
    "flathub:app/md.obsidian.Obsidian/x86_64/stable"
    "flathub:app/org.gimp.GIMP/x86_64/stable"
    "flathub:app/org.kde.krita/x86_64/stable"
    "flathub:app/org.inkscape.Inkscape/x86_64/stable"
  ];
}
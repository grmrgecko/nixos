{pkgs, settings, ...}:

{
  programs.git = {
    enable = true;
    userName = settings.git.name;
    userEmail = settings.git.email;
  };
}
rec {
  system = "x86_64-linux";
  timezone = "America/Chicago";
  locale = "en_US.UTF-8";
  packages = "unstable";
  profile = "desktop";
  hostId = (builtins.substring 0 8 (builtins.readFile "/etc/machine-id"));
  hostName = "nixos";
  videoDrivers = "unknown";
  disk = {
    device = "/dev/sda";
    swapSize = "8G";
    luks = false;
  };
  user = {
    name = "grmrgecko";
    description = "James Coleman";
    hashedPassword = "";
    openssh.authorizedKeys.keys = [];
    autoLogin = false;
  };
  root = {
    hashedPassword = user.hashedPassword;
    openssh.authorizedKeys.keys = user.openssh.authorizedKeys.keys;
  };
  git = {
    name = "GRMrGecko";
    email = "grmrgecko@gmail.com";
  };
  networkmanager.profiles = {};
}
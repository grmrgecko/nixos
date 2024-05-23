rec {
  system = "x86_64-linux";
  timezone = "America/Chicago";
  locale = "en_US.UTF-8";
  packages = "stable";
  profile = "virtual-machine-host";
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
  network.interface = "enp1s0";
  network.suffix = "2";
  networkmanager.profiles = {
    ${network.interface} = {
      connection = {
        id = network.interface;
        type = "ethernet";
        interface-name = network.interface;
      };
      ethernet = {
        mtu = 9000;
      };
      ipv4 = {
        method = "disabled";
      };
      ipv6 = {
        method = "disabled";
      };
    };
    "vlan-${network.interface}.1" = {
      connection = {
        id = "vlan-${network.interface}.1";
        type = "vlan";
        interface-name = "${network.interface}.1";
        master = "br0";
        slave-type = "bridge";
      };
      ethernet = {
        mtu = 1500;
      };
      vlan = {
        flags = 1;
        id = 1;
        parent = network.interface;
      };
    };
    "vlan-${network.interface}.10" = {
      connection = {
        id = "vlan-${network.interface}.10";
        type = "vlan";
        interface-name = "${network.interface}.10";
        master = "br1";
        slave-type = "bridge";
      };
      ethernet = {
        mtu = 1500;
      };
      vlan = {
        flags = 1;
        id = 10;
        parent = network.interface;
      };
    };
    "vlan-${network.interface}.100" = {
      connection = {
        id = "vlan-${network.interface}.100";
        type = "vlan";
        interface-name = "${network.interface}.100";
      };
      ethernet = {
        mtu = 9000;
      };
      vlan = {
        flags = 1;
        id = 100;
        parent = network.interface;
      };
      ipv4 = {
        address1 = "10.0.100.${network.suffix}/24";
        method = "manual";
      };
      ipv6 = {
        method = "disabled";
      };
    };
    "bridge-br0" = {
      connection = {
        id = "bridge-br0";
        type = "bridge";
        interface-name = "br0";
      };
      ipv4 = {
        address1 = "10.0.0.${network.suffix}/24,10.0.0.1";
        dns = "10.0.0.33;10.0.0.1;";
        method = "manual";
      };
      ipv6 = {
        addr-gen-mode = "stable-privacy";
        method = "auto";
      };
    };
    "bridge-br1" = {
      connection = {
        id = "bridge-br1";
        type = "bridge";
        interface-name = "br1";
      };
      ipv4 = {
        address1 = "10.0.10.${network.suffix}/24";
        method = "manual";
      };
      ipv6 = {
        method = "disabled";
      };
    };
  };
}
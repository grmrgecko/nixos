{
  device ? throw "Set this to your disk device, e.g. /dev/disk/by-id/id",
  swapSize ? "8G",
  ...
}: {
  disko.devices = {
    disk.main = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "boot";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountOptions = [ "fmask=0022" "dmask=0022" ];
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];

              subvolumes = {
                "/root" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/";
                };

                "/home" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };

                "/nix" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/nix";
                };

                "/swap" = {
                  mountOptions = [ "noatime" ];
                  mountpoint = "/swap";
                  swap.swapfile.size = swapSize;
                };
              };
            };
          };
        };
      };
    };
  };
}

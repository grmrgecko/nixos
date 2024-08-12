# nixos
These are my configurations for nixos. You are free to use it, however it may be best for you to fork and make your own.

## Installing
In my experience, you need a larger disk size for the nix store on the installer than is created. As such, I use a NFS mount with a swap file. If you are installing using an USB stick, you can probably place a swap file there.

```bash
nix-shell -p git nfs-utils
mkdir /mnt/merged
mount.nfs 10.0.0.5:/mnt/merged /mnt/merged
mkdir /mnt/merged/nixos-tmp
fallocate -l 30G /mnt/merged/nixos-tmp/swap
chmod 600 /mnt/merged/nixos-tmp/swap
mkswap /mnt/merged/nixos-tmp/swap
swapon /mnt/merged/nixos-tmp/swap
mount -o remount,size=20G,noatime /nix/.rw-store
git clone --recursive https://github.com/GRMrGecko/nixos.git
```
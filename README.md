# nixos
These are my configurations for nixos. You are free to use it, however it may be best for you to fork and make your own.

## Installing
In my experience, you need a larger disk size for the nix store on the installer than is created. As such, I use a swap file/drive, recommended separate drive from the one being installed to.

### Swap example.

```bash
mkdir /mnt/usb
mount /dev/sdb1 /mnt/usb
fallocate -l 30G /mnt/usb/swap
chmod 600 /mnt/usb/swap
mkswap /mnt/usb/swap
swapon /mnt/usn/swap
mount -o remount,size=20G,noatime /nix/.rw-store
```

### The install process.

After setting up the extra swap space, clone and enter the nixos repo.
```bash
nix-shell -p git
git clone --recursive https://github.com/GRMrGecko/nixos.git
cd nixos/
```

After you get into the repo, configure the machine to your liking.
```bash
./configure.sh
```

After configuring, install. You can define a tmpdir as the USB drive with `TMPDIR=/mnt/usb` if you want to reduce load on RAM.
```bash
./install.sh --disk main /dev/sda
```

After install is complete, you can then rsync the nixos dir to the user account on the install:
```bash
nix-shell -p rsync
mount -o compress=zstd /dev/mapper/crypted /mnt/hdd
rsync -av /root/nixos/ /mnt/hdd/home/grmrgecko/nixos/
```

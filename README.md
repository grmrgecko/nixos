# nixos
These are my configurations for nixos. You are free to use it, however it may be best for you to fork and make your own.

## Installing
You can install locally, or remote using [nixos anywhere](https://github.com/nix-community/nixos-anywhere). My suggestion is to use the remote method if possible.

### NixOS Anywhere
- Download this repo.
```bash
nix-shell -p git
git clone --recursive https://github.com/GRMrGecko/nixos.git
cd nixos/
```
- Ensure you have ssh acces with keys.
- Configure the configuration for the remote machine, entering root@IPADDR for the system you're configuring.
```bash
./configure.sh
```
- Run the installer, entering root@IPADDR for the system you're installing on.
```bash
./install.sh
```
- After first boot, copy over the nixos dir to make it easy to rebuild and update.
```bash
./rsync.sh --include-settings user@IPADDR
```

### Install on local system

#### Swap example
On systems with a small amount of RAM, you may wish to add an USB drive and attach it as a virtual swap.
This is a small example of how to do so, you will need to update to fit your sitation.

```bash
mkdir /mnt/usb
mount /dev/sdb1 /mnt/usb
fallocate -l 30G /mnt/usb/swap
chmod 600 /mnt/usb/swap
mkswap /mnt/usb/swap
swapon /mnt/usn/swap
mount -o remount,size=20G,noatime /nix/.rw-store
```

#### The install process.
- clone and enter the nixos repo.
```bash
nix-shell -p git
git clone --recursive https://github.com/GRMrGecko/nixos.git
cd nixos/
```
- Configure the machine to your liking.
```bash
./configure.sh
```
- Install. You can define a tmpdir as the USB drive with `TMPDIR=/mnt/usb` if you want to reduce load on RAM.
```bash
./install.sh --disk main /dev/sda
```
- After install is complete, you can then rsync the nixos dir to the user account on the install:
```bash
nix-shell -p rsync
mount -o compress=zstd /dev/mapper/crypted /mnt/hdd
rsync -av /root/nixos/ /mnt/hdd/home/grmrgecko/nixos/
umount /mnt/hdd
```

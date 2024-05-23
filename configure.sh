#!/usr/bin/env bash

# Change into script dir.
cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null || exit
nixosDir=$(pwd)

# Defaults
defaultHostname="nixos"
defaultSwap="8G"
defaultName="grmrgecko"
defaultDescription="James Coleman"
defaultGitName="GRMrGecko"
defaultGitEmail="grmrgecko@gmail.com"

# A simple function to print an array.
CHOICE=0
chooseOpts() {
    local opts i
    CHOICE=-1
    opts=("$@")
    # Keep an index to properly index the options.
    i=0
    echo
    # For each option, print it and increment the index.
    for opt in "${opts[@]}"; do
        echo "$i) $opt"
        i=$((i+1))
    done
    # Ask for their choice.
    echo
    echo -n "Enter choice: "
    read -r CHOICE
    # Check inputted index range.
    if ((CHOICE >= ${#opts[@]} || CHOICE < 0)); then
        echo "Invalid range"
        chooseOpts "$@"
    fi
}

# A looping function to choose Y or N.
chooseYN() {
    local default=""
    if [[ "$1" =~ \[.*([YN]).*\] ]]; then
        default=${BASH_REMATCH[1]}
    fi
    echo -n "$1: "
    read -r CHOICE
    [[ -z $CHOICE ]] && CHOICE=$default
    if [[ "$CHOICE" =~ ^[yY]$ ]]; then
        CHOICE="y"
    elif [[ "$CHOICE" =~ ^[nN]$ ]]; then
        CHOICE="n"
    else
        chooseYN "$1"
    fi
}

# Determine video drivers based on PCI devices.
videoDrivers="unknown"
pciRaw=$(lspci | grep -E 'VGA')
if [[ "$pciRaw" =~ QXL ]]; then
    videoDrivers="qxl"
elif [[ "$pciRaw" =~ NVIDIA ]]; then
    videoDrivers="nvidia"
elif [[ "$pciRaw" =~ AMD ]]; then
    videoDrivers="amdgpu"
fi

# Get the packages souce, rather its unstable or stable.
PACKAGESOPTS=(
    "stable"
    "unstable"
)
echo "Packages source"
chooseOpts "${PACKAGESOPTS[@]}"
PACKAGES=${PACKAGESOPTS[$CHOICE]}

# Get the profile for this system.
PROFILEOPTS=()
# Build profile list from profiles directory.
for profile in ./profiles/*.nix; do
    PROFILEOPTS+=("$(basename "${profile%.*}")")
done
echo "Choose your profile"
chooseOpts "${PROFILEOPTS[@]}"
PROFILE=${PROFILEOPTS[$CHOICE]}

# Get the hostname.
echo -n "Choose hostname [$defaultHostname]: "
read -r hostName
[[ -z $hostName ]] && hostName=$defaultHostname

# Determine default disk.
diskDefault=""
[[ -e /dev/sda ]] && diskDefault="/dev/sda"
[[ -e /dev/vda ]] && diskDefault="/dev/vda"
echo
echo "Select a disk from the list below:"
# List disks to allow a choice to be made without stopping
# configuration and verifying available disks.
lsblk -o PATH,ID-LINK,SIZE -t
echo
echo -n "Choose disk (/dev/disk/by-id/{ID-LINK}) [$diskDefault]: "
read -r disk
# If selected disk is none, use the default disk determined above.
[[ -z $disk ]] && disk=$diskDefault

# Get the swap size.
echo -n "Swap size [$defaultSwap]: "
read -r swapSize
[[ -z $swapSize ]] && swapSize=$defaultSwap

# Determine if we should LUKS encrypt the disk.
luks="false"
chooseYN "Use LUKS Encryption? [N/y]"
if [[ "$CHOICE" == "y" ]]; then
    luks="true"
    # Get a password from the user, with confirmation to ensure
    # we are not setting a typo.
    while true; do
        echo -n "Enter your luks encryption passphrase: "
        read -r -s luksPasswd
        echo -n "Confirm your luks encryption passphrase: "
        read -r -s confirmLuksPasswd
        if [[ "$luksPasswd" == "$confirmLuksPasswd" ]]; then
            break
        fi
        echo "Passwords do not match, try again."
    done
    # Save the password to the tmpfs for disko to pick up during partitioning.
    echo "$luksPasswd" > /tmp/secret.key
fi

# Get username for the main user.
echo -n "Main user name [$defaultName]: "
read -r name
[[ -z $name ]] && name=$defaultName me

# Get description for the main user.
echo -n "Main user description [$defaultDescription]: "
read -r description
[[ -z $description ]] && description=$defaultDescription

# Determine password for main user, verifying no typos.
while true; do
    echo -n "Enter password for main user: "
    read -r -s mainPasswd
    echo -n "Confirm your password for main user: "
    read -r -s confirmMainPasswd
    if [[ "$mainPasswd" == "$confirmMainPasswd" ]]; then
        break
    fi
    echo "Passwords do not match, try again."
done
# Use mkpasswd to create a hashed password with the lastest
# linux password hashing algorithm.
password=$(mkpasswd "$mainPasswd")

# Determine SSH keys to allow into the system.
sshKeys=()
while true; do
    echo "To exit loop, press enter."
    echo -n "Add ssh key (Github Username or ssh key): "
    read -r keyToAdd

    # If empty, exit loop as all keys were selected.
    [[ -z $keyToAdd ]] && break

    # If matches an ssh public key, add to list.
    if [[ "$keyToAdd" =~ ^ssh-.* ]]; then
        echo "Added key: $keyToAdd"
        sshKeys+=("$keyToAdd")
        continue
    fi

    # If is an username, check github for all keys and add them.
    if [[ "$keyToAdd" =~ ([a-zA-Z0-9]+) ]]; then
        githubUsername=${BASH_REMATCH[1]}
        while read -r key; do
            if [[ $key == "Not Found" ]]; then
                echo "Github user provided not found"
                continue
            fi
            echo "Adding key: $key"
            sshKeys+=("$key")
        done < <(curl -s -q "https://github.com/$githubUsername.keys")
    fi
done

# Determine if we want to autologin to the main user,
# this may be desirable on full disk encrypted machines.
autoLogin="false"
chooseYN "Autologin to main user? [N/y]"
if [[ "$CHOICE" == "y" ]]; then
    autoLogin="true"
fi

# Get git name.
echo -n "Git name [$defaultGitName]: "
read -r gitName
[[ -z $gitName ]] && gitName=$defaultGitName me

# Get git email.
echo -n "Git email [$defaultGitEmail]: "
read -r gitEmail
[[ -z $gitEmail ]] && gitEmail=$defaultGitEmail

# Generate settings.nix file with above choosen options.
echo "Generating settings.nix:"
cat <<EOF | tee "$nixosDir/settings.nix"
rec {
  system = "x86_64-linux";
  timezone = "America/Chicago";
  locale = "en_US.UTF-8";
  packages = "${PACKAGES}";
  profile = "${PROFILE}";
  hostId = (builtins.substring 0 8 (builtins.readFile "/etc/machine-id"));
  hostName = "${hostName}";
  videoDrivers = "${videoDrivers}";
  disk = {
    device = "${disk}";
    swapSize = "${swapSize}";
    luks = ${luks};
  };
  user = {
    name = "${name}";
    description = "${description}";
    hashedPassword = "${password}";
    openssh.authorizedKeys.keys = [$(printf ' "%s"' "${sshKeys[@]}") ];
    autoLogin = ${autoLogin};
  };
  root = {
    hashedPassword = user.hashedPassword;
    openssh.authorizedKeys.keys = user.openssh.authorizedKeys.keys;
  };
  git = {
    name = "${gitName}";
    email = "${gitEmail}";
  };
  networkmanager.profiles = {};
}
EOF

# Generate hardware-configuration.nix without filesystems as we use the disko partitoning flake.
echo
echo "Generating hardware-configuration.nix"
nixos-generate-config --no-filesystems --show-hardware-config | tee "$nixosDir/hardware-configuration.nix"

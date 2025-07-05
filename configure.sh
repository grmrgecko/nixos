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
    # Determine the default based on upper case Y or N in prompt.
    local default=""
    if [[ "$1" =~ \[.*([YN]).*\] ]]; then
        default=${BASH_REMATCH[1]}
    fi

    # Loop for the choice.
    while true; do
        # Prompt for choice.
        echo -n "$1: "
        read -r CHOICE

        # If choice is empty, set choice to the default.
        [[ -z $CHOICE ]] && CHOICE=$default

        # If choice does not equal Y or N, continue.
        # Otherwise set the global CHOICE variable to lowercase y or n.
        # Lowercase allows for easy logic in code that calls this function.
        if [[ "$CHOICE" =~ ^[yY]$ ]]; then
            CHOICE="y"
        elif [[ "$CHOICE" =~ ^[nN]$ ]]; then
            CHOICE="n"
        else
            continue
        fi
        break
    done
}

remoteAddr=""
echo "If you are configuring a remote machine, ensure you have ssh access with keys."
echo -n "Configuring [local machine]: "
read -r CHOICE
if [[ -n $CHOICE ]]; then
    remoteAddr="$CHOICE"
fi
sshCmd=""
if [[ -n $remoteAddr ]]; then
    if ssh "$remoteAddr" /usr/bin/env true; then
        sshCmd="ssh $remoteAddr"
    else
        echo "Unable to confirm connection to remote $remoteAddr"
    fi
fi

# Determine video drivers based on PCI devices.
videoDrivers="unknown"
pciRaw=$($sshCmd lspci | grep -E 'VGA')
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
$sshCmd lsblk -o PATH,ID-LINK,SIZE -t
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
        echo
        echo -n "Confirm your luks encryption passphrase: "
        read -r -s confirmLuksPasswd
        echo
        if [[ "$luksPasswd" == "$confirmLuksPasswd" ]]; then
            break
        fi
        echo "Passwords do not match, try again."
    done
    # Save the password to the tmpfs for disko to pick up during partitioning.
    echo -n "$luksPasswd" | $sshCmd dd of=/tmp/secret.key
fi

# Get username for the main user.
echo -n "Main user name [$defaultName]: "
read -r name
[[ -z $name ]] && name=$defaultName

# Get description for the main user.
echo -n "Main user description [$defaultDescription]: "
read -r description
[[ -z $description ]] && description=$defaultDescription

# Determine password for main user, verifying no typos.
while true; do
    echo -n "Enter password for main user: "
    read -r -s mainPasswd
    echo
    echo -n "Confirm your password for main user: "
    read -r -s confirmMainPasswd
    echo
    if [[ "$mainPasswd" == "$confirmMainPasswd" ]]; then
        break
    fi
    echo "Passwords do not match, try again."
done
# Use mkpasswd to create a hashed password with the lastest
# linux password hashing algorithm.
password=$($sshCmd mkpasswd "\"$mainPasswd\"")

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
[[ -z $gitName ]] && gitName=$defaultGitName

# Get git email.
echo -n "Git email [$defaultGitEmail]: "
read -r gitEmail
[[ -z $gitEmail ]] && gitEmail=$defaultGitEmail

# Generate settings.nix file with above choosen options.
echo "Generating settings.nix:"
cat <<EOF | tee "$nixosDir/settings.nix"
rec {
  system = "$($sshCmd uname -m)-linux";
  timezone = "America/Chicago";
  locale = "en_US.UTF-8";
  packages = "${PACKAGES}";
  profile = "${PROFILE}";
  hostId = "$($sshCmd tr -dc a-f0-9 </dev/urandom | head -c 8)";
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
$sshCmd nixos-generate-config --no-filesystems --show-hardware-config | tee "$nixosDir/hardware-configuration.nix"

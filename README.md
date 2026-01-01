# DSEE-NIX Configuration Repository

## Overview

This repository contains a nix flake that exposes:

- NixOS modules for DSEE machines
- Home Manager modules for DSEE user environments
- A Development Shell for some CI maintenance
- Selected packages useful for DSEE users
- A simple NixOS system module for testing

A large part of the configuration is conditional on `hostSpec` and `userSpec` settings. You can find the availale options [here](https://ude-fakwiwi.pages.git.nrw/dsee/nixos/nixosconfigurations/dsee-common). In your Home Manager configurations you can use `userSpec.me` to refer to the `userSpec` settings of the respective user.

## Usage

This flake is not meant to be used directly, instead it is intended to be imported.

You can use the test configuration as a starting point:

TODO: Add minimal flake here

## Deployment via NixOS Anywhere

You can deploy the NixOS configurations using [NixOS Anywhere](https://github.com/nix-community/nixos-anywhere):

Boot the target machine (e.g., using a live USB) and set the root password using `sudo passwd`. Find the ip adress using `ip a` and double check the disk name that you want to install to using `sudo lsblk` (e.g. `/dev/nvme0n1`). 

> [!Important] Disk Name
> If the disk name is not `/dev/nvme0n1` you need to supply it by setting: `disko.devices.disk.main.device` in your [flake.nix](./flake.nix#L140).

> [!Important] System Stateversion
> Make sure that `system.stateVersion = "26.05"` is up-to-date in your [flake.nix](./flake.nix#L136).

Now, on your local machine, assign the IP address of the target to `TARGET` (for convenience):

```sh
export TARGET=192.168.178.211
```

Save the luks password:

```sh
echo "test" > /tmp/secret.key
```


Set the SSH password to the `SSHPASS` variable:

```sh
export SSHPASS='test'
```

Now you can run the installation command:

> [!Warning] 
> The next command will erase all data on the `TARGET`!

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake .#test \
  --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  --disk-encryption-keys /tmp/secret.key /tmp/secret.key \
  --env-password \
  --target-host root@$TARGET
```

## Testing

To check the flake, you can use the following command:

```sh
nix flake check --print-build-logs
```

You can also create a VM to test the NixOS configuration:

```sh
nixos-rebuild build-vm --flake .#test
```

You can also test the whole installation process including the disko formatting in a VM:

(needs to be fixed)

```sh
nix run github:nix-community/nixos-anywhere -- \
  --flake .#test \
  --vm-test
```
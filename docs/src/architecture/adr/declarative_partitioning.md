# Declarative Partitioning

## Status

Proposed

## Context

On Ghaf, the aim is to describe the system as code. This has not yet fully been realized in creation of system persistent memory partitions (partitioning) and creating filesystems to partitions (formatting). As of now, the Ghaf target systems are built into disk images with simple, inflexible and non-existent disk partioning. Ghaf systems have fixed size root partition with the host and guest virtual machines. Statically fixed size of root partition is created built time and resizing is not flexible. Currently, the Ghaf systems are built into system images which are either written to the device persistent memory over USB (flashing) or written to external bootable media which is copied to the device persistent memory after booting.

A Ghaf goal is to decouple the host and guest virtual machines from their data to protect the data at rest. In addition to the system and data partitions requirements, the host system update (A/B) mechanism will require partitions to support the update.

The proposed mechanism includes:
- common declarative format to describe the reference partitioning scheme across target devices
- support changes to partition sizes (e.g. Logical Volume Manager - LVM) (at least in development)
- support encryption of partitions (e.g. Linux Unified Key Setup - LUKS) for data
- support elimination of passwords (e.g. Fast Identity Online - FIDO) with public-key cryptography
- decouple partitioning and formatting from target device image creation or system installation

NixOS, and traditional Linux distributions, share some of the aforementioned issues - users must complete partitioning and formatting before the system installation and it typically takes place manually, not declaratively.

## Evaluated solution

[Disko](https://github.com/nix-community/disko) provides a NixOS compatible solution to declarative partitioning. This subsection presents evaluation of disko with the `aarch64` and generic `x64_64` target devices on Ghaf. Evaluation results are presented in the following table:

| Feature    | `aarch64` support | `x86-64` support |
|------------|-------------------|------------------|
| GPT layout |        X          |      TDE         |
| LVM        |        TDE        |      TDE         |
| ext4       |        X          |      TDE         |
| tmpfs      |        TDE        |      TDE         |


## Evaluation

### Test - Declarative partitioning of removable media
```
$ curl https://raw.githubusercontent.com/nix-community/disko/master/example/simple-efi.nix -o /tmp/disko-config.nix
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   694  100   694    0     0   6723      0 --:--:-- --:--:-- --:--:--  6673

# modify device = "/dev/disk/by-id/some-disk-id"; to device = "/dev/sda"; (or whatever your removable media enumerates to) 
# for some reason --args disks '[ "/dev/sda" ]' did not get passed via disko to replace the device in disko-config.nix

$ sudo nix run github:nix-community/disko -- --mode disko /tmp/disko-config.nix --arg disks '[ "/dev/sda" ]'
this derivation will be built:
  /nix/store/gcwy33wnddn474m5rg3w7bzc550yxsvw-disko.drv
building '/nix/store/gcwy33wnddn474m5rg3w7bzc550yxsvw-disko.drv'...
umount: /mnt: not found
++ realpath /dev/sda
+ disk=/dev/sda
+ lsblk --output-all --json
++ dirname /nix/store/2mjq3hk6515sgajn2778169w1nkls56h-disk-deactivate/disk-deactivate
+ jq -r --arg disk_to_clear /dev/sda -f /nix/store/2mjq3hk6515sgajn2778169w1nkls56h-disk-deactivate/disk-deactivate.jq
+ set -fu
+ wipefs --all -f /dev/sda1
/dev/sda1: 8 bytes were erased at offset 0x00000036 (vfat): 46 41 54 31 36 20 20 20
/dev/sda1: 1 byte was erased at offset 0x00000000 (vfat): eb
/dev/sda1: 2 bytes were erased at offset 0x000001fe (vfat): 55 aa
++ zdb -l /dev/sda2
bash: line 3: zdb: command not found
++ sed -nr 's/ +name: '\''(.*)'\''/\1/p'
+ zpool=
+ [[ -n '' ]]
+ unset zpool
+ wipefs --all -f /dev/sda2
++ zdb -l /dev/sda
++ sed -nr 's/ +name: '\''(.*)'\''/\1/p'
bash: line 7: zdb: command not found
+ zpool=
+ [[ -n '' ]]
+ unset zpool
+ wipefs --all -f /dev/sda
/dev/sda: 8 bytes were erased at offset 0x00000200 (gpt): 45 46 49 20 50 41 52 54
/dev/sda: 8 bytes were erased at offset 0x3a37fffe00 (gpt): 45 46 49 20 50 41 52 54
/dev/sda: 2 bytes were erased at offset 0x000001fe (PMBR): 55 aa
++ mktemp -d
+ disko_devices_dir=/tmp/tmp.J41QXMZky5
+ trap 'rm -rf "$disko_devices_dir"' EXIT
+ mkdir -p /tmp/tmp.J41QXMZky5
+ device=/dev/sda
+ imageSize=2G
+ name=vdb
+ type=disk
+ device=/dev/sda
+ type=gpt
+ sgdisk --new=1:0:+100M --change-name=1:disk-vdb-ESP --typecode=1:EF00 /dev/sda
Creating new GPT entries in memory.
The operation has completed successfully.
+ udevadm trigger --subsystem-match=block
+ udevadm settle
+ device=/dev/disk/by-partlabel/disk-vdb-ESP
+ extraArgs=()
+ declare -a extraArgs
+ format=vfat
+ mountOptions=('defaults')
+ declare -a mountOptions
+ mountpoint=/boot
+ type=filesystem
+ mkfs.vfat /dev/disk/by-partlabel/disk-vdb-ESP
mkfs.fat 4.2 (2021-01-31)
+ sgdisk --new=2:0:-0 --change-name=2:disk-vdb-root --typecode=2:8300 /dev/sda
The operation has completed successfully.
+ udevadm trigger --subsystem-match=block
+ udevadm settle
+ device=/dev/disk/by-partlabel/disk-vdb-root
+ extraArgs=()
+ declare -a extraArgs
+ format=ext4
+ mountOptions=('defaults')
+ declare -a mountOptions
+ mountpoint=/
+ type=filesystem
+ mkfs.ext4 /dev/disk/by-partlabel/disk-vdb-root
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 61020920 4k blocks and 15261696 inodes
Filesystem UUID: eddd5e93-8ab9-419c-b035-401dae0570aa
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done     

+ set -efux
+ findmnt /dev/disk/by-partlabel/disk-vdb-root /mnt/
+ mount /dev/disk/by-partlabel/disk-vdb-root /mnt/ -t ext4 -o defaults -o X-mount.mkdir
+ findmnt /dev/disk/by-partlabel/disk-vdb-ESP /mnt/boot
+ mount /dev/disk/by-partlabel/disk-vdb-ESP /mnt/boot -t vfat -o defaults -o X-mount.mkdir
+ rm -rf /tmp/tmp.J41QXMZky5

# Please note a few lines of "bash: line <n>: zdb: command not found" - this is probably assumed in environment
# on NixOS installer at https://github.com/nix-community/disko/blob/master/docs/quickstart.md#step-2-boot-the-installer
# of quickstart documentation. Given disko uses flake, missing zdb could be added via zfs from nixpkgs to support disko
# also in the context of not on NixOS installer. It's notable that declarative partitioning and mount works nevertheless: 

$ mount | grep sda
/dev/sda2 on /mnt type ext4 (rw,relatime)
/dev/sda1 on /mnt/boot type vfat (rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro)
```
### Test - boot NixOS aarch64 installer on NVIDIA Orin AGX

```
❯ sudo dd if=nixos-minimal-new-kernel-23.05pre456191.b69883faca9-aarch64-linux.iso of=/dev/sdb bs=32M status=progress
```

Boots to NixOS installer menu (`default|nomodeset|debug`) on Orin AGX but does not boot to installer shell nor give any errors to serial debug.
This blocks testing `disko` on the Orin AGX internal persistent memory. One solution could be to build a custom initrd or Unified Kernel Image based on Jetson BSP and test with that.

### Test - boot aarch64 jetpack-nixos installer on NVIDIA Orin NX

1. Clone https://github.com/anduril/jetpack-nixos and add your public ssh keys to `installer_minimal_config { };` in [jetpack-nixos flake.nix](https://github.com/anduril/jetpack-nixos/blob/master/flake.nix) like:
```
    installer_minimal_config = {
      ...
      users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdNDuKwAsAff4iFRfujo77W4cyAbfQHjHP57h/7tJde ville.ilvonen@unikie.com" ];
      users.users.nixos.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdNDuKwAsAff4iFRfujo77W4cyAbfQHjHP57h/7tJde ville.ilvonen@unikie.com" ];
      ...
    };
```
(1.-step is needed due to out-of-the-box display and serial access issues on Orin NX)
2. Build the modified ISO with `nix build .#iso_minimal`
3. Write the ISO to USB removable media
4. Boot NVIDIA Orin NX with the USB removable media from previous step
5. Connect the Orin NX to ethernet and login with your ssh key
   (e.g. `ssh -i <your_private_key> root@1.2.3.4`)
6. Check the Orin NX persistent media partitions with `lsblk`:
```
[root@nixos:~]# lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0 726.8M  1 loop /nix/.ro-store
sda            8:0    1 232.9G  0 disk /iso
nvme0n1      259:0    0 465.8G  0 disk
├─nvme0n1p1  259:1    0   465G  0 part
├─nvme0n1p2  259:2    0    64M  0 part
├─nvme0n1p3  259:3    0   448K  0 part
├─nvme0n1p4  259:4    0    32M  0 part
├─nvme0n1p5  259:5    0    64M  0 part
├─nvme0n1p6  259:6    0   448K  0 part
├─nvme0n1p7  259:7    0    32M  0 part
├─nvme0n1p8  259:8    0    80M  0 part
├─nvme0n1p9  259:9    0   512K  0 part
├─nvme0n1p10 259:10   0   300M  0 part
├─nvme0n1p11 259:11   0    64M  0 part
├─nvme0n1p12 259:12   0    80M  0 part
├─nvme0n1p13 259:13   0   512K  0 part
└─nvme0n1p14 259:14   0    64M  0 part
```
(above partitions on `nvme0n1` reflect the NVIDIA jetpack-based Ubuntu)
7. Run `disko` with `nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko -- --mode disko ./disko-config.nix --arg disks '[ "/dev/nvme0n1" ]'`

using the following config (`./disko-config.nix`):

```
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
```
8. Verify created partitions
```
[root@nixos:~]# lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0 726.8M  1 loop /nix/.ro-store
sda           8:0    1 232.9G  0 disk /iso
nvme0n1     259:0    0 465.8G  0 disk
├─nvme0n1p1 259:1    0   512M  0 part /mnt/boot
├─nvme0n1p2 259:2    0     1M  0 part
└─nvme0n1p3 259:3    0 465.3G  0 part /mnt
```
9. Generate NixOS config with `nixos-generate-config --root /mnt/`
10. Modify `/mnt/etc/nixos/configuration.nix` with:
```
  imports =
    [
      ./hardware-configuration.nix
      (builtins.fetchTarball "https://github.com/anduril/jetpack-nixos/archive/master.tar.gz" + "/modules/default.nix")
    ];

  hardware.nvidia-jetpack.enable = true;
  hardware.nvidia-jetpack.som = "xavier-nx";
  hardware.nvidia-jetpack.carrierBoard = "devkit";
```
11. Install NixOS with `nixos-install`
12. Boot to NixOS after installation finishes

## Decision

1. Use `disko`-module via flake input
```
{
	inputs.disko.url = "github:nix-community/disko";
    ...
	modules = [
	  ...
	  disko.nixosModules.disko`
	]
}
```

and declare the reference filesystem for target systems.
```
TBD
```

2. Change the supported default target system installation method from flashing or writing the image to installer-based with declarative partitioning support.

## Consequences

For unattended installation and ease-of-use comparable to flashing, declarative partitioning requires an installer that can bootstrap the system to run the partitioning before installation. In the first phase, a generic `x86_64` or `aarch64` UEFI installer can be used to boot a target device and then Ghaf with the filesystem partitioning can be run unattended from shell. In the second phase, shell can be replaced with a graphical installer.

Declarative partitioning and flashing are not necessarily overlapping but will require changes on how target device images are generated.

Declarative partitioning with target-specific hardware module would enable development of generic, per hardware architecture installer that would allow selection of the specific target device. This would reduce the need to support specific target devices at build time.

<!-- What becomes easier or more difficult to do because of this change? -->

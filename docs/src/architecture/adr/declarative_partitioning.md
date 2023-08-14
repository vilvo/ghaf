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
| GPT layout |        TDE        |      TDE            |
| LVM        |        TDE        |      TDE            |
| ext4       |        TDE        |      TDE            |
| tmpfs      |        TDE        |      TDE            |

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

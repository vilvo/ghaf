# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  pkgs,
  ...
}: let
  baseKernel = pkgs.linux_latest;

  hardened_kernel = pkgs.linuxManualConfig rec {
    inherit (baseKernel) src modDirVersion;
    version = "${baseKernel.version}-ghaf-hardened";
    configfile = ./minimal_kernel_config_x86_86;
    allowImportFromDerivation = true;
  };
in
{
  boot.kernelPackages = pkgs.linuxPackagesFor hardened_kernel;
  # https://github.com/NixOS/nixpkgs/issues/109280#issuecomment-973636212
  nixpkgs.overlays = [
    (final: prev: {
      makeModulesClosure = x:
        prev.makeModulesClosure (x // {allowMissing = true;});
    })
  ];
}

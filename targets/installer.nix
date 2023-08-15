# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Generic x86_64 (for now) computer installer
{
  self,
  nixos-generators,
  lib,
}: let
  formatModule = nixos-generators.nixosModules.raw-efi;
  installer = {name, systemImgCfg}: let
    system = systemImgCfg.config.nixpkgs.hostPlatform.system;
    systemImgDrv = systemImgCfg.config.system.build.${systemImgCfg.config.formatAttr};
    installerImgCfg = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit (self) lib;};
      modules =
        [
          ../modules/host
          {
            ghaf = {
              hardware.x86_64.common.enable = true;
              profiles.installer.enable = true;
            };
          }

          {
            # TODO
            environment.loginShellInit = ''
              cp -r ${systemImgDrv} ~/systemImage
            '';
          }

          formatModule
        ]
        ++ (import ../modules/module-list.nix);
    };
  in {
    name = "${name}-installer";
    inherit installerImgCfg installerImgDrv system;
  };
  targets = map installer [{name = "generic-x86-release"; systemImgCfg = self.nixosConfigurations.generic-x86_64-release;}];
in {
  packages = lib.foldr lib.recursiveUpdate {} (map ({name, system, installerImgDrv, ...}: {
    ${system}.${name} = installerImgDrv;
  }) targets);
}

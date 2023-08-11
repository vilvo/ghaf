# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
# Generic x86_64 (for now) computer installer
{
  self,
  nixos-generators,
  lib,
}: let
  name = "generic-installer-x86_64";
  system = "x86_64-linux";
  formatModule = nixos-generators.nixosModules.raw-efi;
  generic-installer-x86 = let
    hostConfiguration = lib.nixosSystem {
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

          formatModule
        ]
        ++ (import ../modules/module-list.nix);
    };
  in {
    inherit hostConfiguration name;
    package = hostConfiguration.config.system.build.${hostConfiguration.config.formatAttr};
  };
  targets = [generic-installer-x86];
in {
  nixosConfigurations =
    builtins.listToAttrs (map (t: lib.nameValuePair t.name t.hostConfiguration) targets);
  packages = {
    x86_64-linux =
      builtins.listToAttrs (map (t: lib.nameValuePair t.name t.package) targets);
  };
}

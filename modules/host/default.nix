# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  pkgs,
  ...
}:
let
  vhost-device = pkgs.callPackage ../../packages/vhost-device {};
in {
  imports = [
    # TODO remove this when the minimal config is defined
    # Replace with the baseModules definition
    # UPDATE 26.07.2023:
    # This line breaks build of GUIVM. No investigations of a
    # root cause are done so far.
    #(modulesPath + "/profiles/minimal.nix")

    ../../overlays/custom-packages

    ./kernel.nix

    # TODO: Refactor this under virtualization/microvm/host/networking.nix
    ./networking.nix
  ];

  config = {
    networking.hostName = "ghaf-host";
    system.stateVersion = lib.trivial.release;

    systemd.services.vhost-device-vsock = {
      enable = true;
      description = "vhost-device-vsock";
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        ExecStart = "${vhost-device}/bin/vhost-device-vsock --vm guest-cid=3,uds-path=/tmp/vm3.vsock,socket=/tmp/vhost3.socket --vm guest-cid=4,uds-path=/tmp/vm4.vsock,socket=/tmp/vhost4.socket";
      };
      wantedBy = ["multi-user.target"];
    };

    ####
    # temp means to reduce the image size
    # TODO remove this when the minimal config is defined
    appstream.enable = false;

    systemd.package = pkgs.systemd.override ({
        withCryptsetup = false;
        withDocumentation = false;
        withFido2 = false;
        withHomed = false;
        withHwdb = false;
        withLibBPF = true;
        withLocaled = false;
        withPCRE2 = false;
        withPortabled = false;
        withTpm2Tss = false;
        withUserDb = false;
      }
      // lib.optionalAttrs (lib.hasAttr "withRepart" (lib.functionArgs pkgs.systemd.override)) {
        withRepart = false;
      });

    boot.enableContainers = false;
    ##### Remove to here
  };
}

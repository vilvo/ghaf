# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  config,
  lib,
  ...
}: let
  cfg = config.ghaf.host.kernel_hardening;
in
  with lib; {
    options.ghaf.host.kernel_hardening = {
      enable = mkEnableOption "Host kernel hardening";
    };

  }

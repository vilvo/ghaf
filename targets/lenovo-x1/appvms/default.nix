# Copyright 2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
{
  pkgs,
  lib,
  config,
  ...
}: let
  chromium = import ./chromium.nix {inherit pkgs;};
  gala = import ./gala.nix {inherit pkgs lib config;};
  zathura = import ./zathura.nix {inherit pkgs;};
in [
  chromium
  gala
  zathura
]

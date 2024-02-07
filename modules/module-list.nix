# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
#
#
[
  ./development/debug-tools.nix
  ./development/nix.nix
  ./development/ssh.nix
  ./firewall
  ./graphics
  ./hardware/definition.nix
  ./hardware/nvidia-jetson-orin/optee.nix
  ./hardware/x86_64-linux.nix
  ./hardware/x86_64-generic/kernel/hardening.nix
  ./installer
  ./profiles/applications.nix
  ./profiles/debug.nix
  ./profiles/graphics.nix
  ./profiles/installer.nix
  ./profiles/release.nix
  ./users/accounts.nix
  ./version
  ./virtualization/docker.nix
  ./windows-launcher
]

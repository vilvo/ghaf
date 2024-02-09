{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../default.nix
  ];

  config.ghaf.host.kernel.baseline_hardening.enable = true;
  config.ghaf.host.kernel.virtualization_hardening.enable = true;
  config.ghaf.host.kernel.networking_hardening.enable = true;
  config.ghaf.host.kernel.usb_hardening.enable = true;

  # required to module test a module via top level configuration
  config.boot.loader.systemd-boot.enable = true;
  config.fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };
  config.system.stateVersion = "23.11";
}

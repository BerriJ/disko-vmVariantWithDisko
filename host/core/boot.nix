{
  lib,
  ...
}:
{
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      timeout = 2;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 25;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      systemd = {
        enable = true;
        settings.Manager = {
          DefaultDeviceTimeoutSec = lib.mkDefault "infinity";
        };
      };
    };
  };
}

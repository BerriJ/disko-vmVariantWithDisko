{
  lib,
  ...
}:
{

  virtualisation.vmVariant = {

    # Disable initrd SSH for VM builds
    boot.initrd.network.ssh.enable = lib.mkForce false;
    # Disable clevis for VM builds
    boot.initrd.clevis.enable = lib.mkForce false;
    # Disable secrets for VM builds
    age.secrets = lib.mkForce { };

  };

}

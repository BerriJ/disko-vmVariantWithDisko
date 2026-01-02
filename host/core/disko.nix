{
  lib,
  pkgs,
  ...
}:
{
  # luks-lvm-swap-btrfs
  disko = {
    devices = {
      disk = {
        main = {
          type = "disk";
          device = lib.mkDefault "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              "EFI" = {
                name = "EFI";
                label = lib.mkDefault "EFI";
                size = lib.mkDefault "1024M";
                type = "EF00";
                priority = 100;
                content = {
                  type = "filesystem";
                  format = "vfat";
                  extraArgs = [
                    "-F"
                    "32"
                    "-n"
                    "EFI"
                  ];
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                    "umask=0077"
                  ];
                };
              };
              "main" = {
                name = "main";
                # Pass the label to: boot.initrd.luks.devices.<name>.device
                label = lib.mkDefault "main";
                size = "100%";
                priority = 200;
                content = {
                  type = "luks";
                  name = "main";
                  extraOpenArgs = [ "--allow-discards" ];
                  passwordFile = lib.mkDefault "/tmp/secret.key";
                  askPassword = false;
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "btrfs";
                    extraArgs = [
                      "-f"
                      "-L"
                      "system"
                    ];
                    subvolumes = {
                      "@" = {
                        mountpoint = "/";
                        mountOptions = [ "compress=zstd" ];
                      };
                      "@home" = {
                        mountpoint = "/home";
                        mountOptions = [ "compress=zstd" ];
                      };
                      "@log" = {
                        mountpoint = "/var/log";
                        mountOptions = [ "compress=zstd" ];
                      };
                      "@nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    tests.extraConfig = {

      # This does not work
      # disko.devices.disk.main.content.partitions.main.content.settings.keyFile = "/tmp/secret.key";

      boot.initrd = {
        systemd = {
          services = {
            createLuksKeyFileFile = {
              enable = lib.mkDefault true;
              description = "Create LUKS password file for Disko";
              wantedBy = [ "sysinit.target" ];
              before = [
                "sysinit.target"
                "systemd-cryptsetup.service"
              ];
              path = [ pkgs.coreutils ]; # Makes echo, tee, etc. available
              script = "umask 077; echo -n 'secretsecret' > /tmp/secret.key;";
              unitConfig = {
                DefaultDependencies = "no";
              };
              serviceConfig = {
                Type = "oneshot";
              };
            };
          };
        };
        luks.devices = {
          main = {
            # Works if I do the overwrite here
            keyFile = "/tmp/secret.key";
          };
        };
      };
    };
  };

  # virtualisation.vmVariantWithDisko also does not work
  # virtualisation.vmVariantWithDisko = {
  #   disko.devices.disk.main.content.partitions.main.content.settings.keyFile = "/tmp/secret.key";
  # };

  # Works if I do the overwrite here
  # disko.devices.disk.main.content.partitions.main.content.settings.keyFile = "/tmp/secret.key";

}

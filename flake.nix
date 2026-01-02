{
  description = "NixOS configuration with Disko and LUKS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      disko,
      ...
    }:
    {
      nixosConfigurations.test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./host/core/default.nix
          (_: {
            networking.hostName = "test";
            system.stateVersion = "26.05";
            disko.devices.disk.main.device = "/dev/sda";
          })
        ];
      };
    };
}

{
  description = "Common NixOS configuration flake for DSEE infrastructure";

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      treefmt-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        programs.deadnix.enable = true;
        programs.statix.enable = true;
        settings.formatter = {
          deadnix.priority = 1;
          statix.priority = 2;
          nixfmt.priority = 3;
        };
      };
    in
    {

      nixosModules = {

        core = ./host/core/default.nix;

        default = {
          imports = [
            self.nixosModules.core
          ];
        };

      };

      nixosConfigurations.test = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        inherit system;
        modules = [
          disko.nixosModules.disko
          self.nixosModules.default
          (_: {
            networking.hostName = "test";
            system.stateVersion = "26.05";
            disko.devices.disk.main.device = "/dev/sda";
            disko.devices.lvm_vg."pool".lvs.swap.size = "1G";
          })
        ];
      };

      formatter.x86_64-linux = treefmtEval.config.build.wrapper;

      checks.x86_64-linux = {
        formatting = treefmtEval.config.build.check self;
      };

    };
}

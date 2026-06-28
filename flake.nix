{
  description = "NixOS Configuration Aggregator";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      myLib = import ./lib { inherit lib nixpkgs; };

      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = lib.genAttrs systems;

      overlay = myLib.mkOverlay ./packages;
    in
    {
      overlays.default = overlay;

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
        in
        myLib.discoverPackages ./packages pkgs
      );
     
      nixosConfigurations = {
        web-host = myLib.mkHost {
          system = "x86_64-linux";
          hostPath = ./hosts/web-host/configuration.nix;
          modulesDir = ./modules;
          packagesDir = ./packages;
          selectedModules = [ "web-server" "dev-tools" "networking/firewall-strict" ];
        };

        db-host = myLib.mkHost {
          system = "x86_64-linux";
          hostPath = ./hosts/db-host/configuration.nix;
          modulesDir = ./modules;
          packagesDir = ./packages;
          selectedModules = [ "database" "dev-tools" ];
        };

        full-host = myLib.mkHost {
          system = "x86_64-linux";
          hostPath = ./hosts/full-host/configuration.nix;
          modulesDir = ./modules;
          packagesDir = ./packages;
          selectedModules = [ "web-server" "database" "dev-tools" "networking/firewall-strict" ];
        };

        /*missing-host = myLib.mkHost {
          system = "x86_64-linux";
          hostPath = ./hosts/full-host/configuration.nix;
          modulesDir = ./modules;
	  packagesDir = ./packages;
          selectedModules = [ "web-server" "nonexistent-module" ];
        };

        duplicate-host = myLib.mkHost {
          system = "x86_64-linux";
          hostPath = ./hosts/full-host.configuration.nix;
          modulesDir = ./modules;
          packagesDir = ./packages;
          selectedModules = [ "web-server" "web-server" ];
        };*/
      };
      
      checks = forAllSystems (system: {
        web-host = self.nixosConfigurations.web-host.config.system.build.toplevel;
        db-host = self.nixosConfigurations.db-host.config.system.build.toplevel;
	full-host = self.nixosConfigurations.full-host.config.system.build.toplevel;
      /* missing-host = self.nixosConfigurations.missing-host.config.system.build.toplevel;
        duplicate-host = self.nixosConfigurations.duplicate-host.config.system.build.toplevel;*/
      });
    };
}


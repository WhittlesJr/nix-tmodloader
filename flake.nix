{
  description = "tModLoader dedicated server for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in {
      # Package output for `nix build .#tmodloader-server`
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          tmodloader-server = pkgs.callPackage ./pkgs/default.nix {};
          default = self.packages.${system}.tmodloader-server;
        });

      # Overlay for adding to pkgs
      overlays.default = final: prev: {
        tmodloader-server = final.callPackage ./pkgs/default.nix {};
      };

      # NixOS module - applies overlay automatically
      nixosModules.tmodloader = { ... }: {
        imports = [ ./module ];
        nixpkgs.overlays = [ self.overlays.default ];
      };

      nixosModules.default = self.nixosModules.tmodloader;
    };
}

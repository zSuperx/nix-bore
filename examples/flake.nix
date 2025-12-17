{
  description = "NixOS module for the Bore TCP tunnel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-bore.url = "github:zSuperx/nix-bore";
  };

  outputs =
    { nixpkgs, nix-bore, ... }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nix-bore.nixosModules.bore
          ./local.nix
          ./server.nix
        ];
      };
    };
}

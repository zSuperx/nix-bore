{
  description = "NixOS module for the Bore TCP tunnel";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = _: {
    nixosModules = rec {
      bore = import ./module/bore.nix;
      default = bore;
    };
  };
}

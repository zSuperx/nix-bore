{
  description = "Example usage of nix-bore NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-bore.url = "github:zSuperx/nix-bore"; # Add to inputs
  };

  outputs =
    { nixpkgs, ... }: # Add to inputs
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import module
          # nix-bore.nixosModules.bore

          # Bore local examples
          {
            services.bore = {
              local = {
                minecraft = {
                  enable = true;
                  to = "mc.piyush.ai";
                  remote-port = 6969;
                  local-port = 6969;
                  secretFile = "/run/keys/bore.secret";
                };

                other-thing = {
                  enable = true;
                  remote-port = 6969;
                  local-port = 6969;
                  to = "bore.pub";
                };
              };
            };
          }

          # Bore server examples
          {
            services.bore.servers = {
              minecraft-proxy = {
                enable = true;
                secretFile = "/run/keys/bore.secret";
              };

              minecraft-proxy2 = {
                enable = false;
                bind-addr = "0.0.0.0";
              };
            };
          }
        ];
      };
    };
}

{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.services.bore;
in
{
  imports = [
    ./server
    ./local
  ];

  options = {
    services.bore = {
      package = mkOption {
        type = types.package;
        default = pkgs.bore-cli;
        description = ''
          The bore package to use.
        '';
      };

      skipLocalPortCheck = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Skip address/port duplication check for local proxies.
        '';
      };

      skipServerPortCheck = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Skip address/port duplication check for remote proxy servers.
        '';
      };
    };
  };

  config =
    let
      extractLocalAddrs =
        servers:
        (lib.mapAttrsToList (
          _: value: with value; "${local-host}:${builtins.toString local-port}"
        ) servers);
      extractRemoteAddrs = servers: (lib.mapAttrsToList (_: value: value.bind-addr) servers);
    in
    {
      assertions = [
        (lib.mkIf (!cfg.skipLocalPortCheck) {
          assertion = lib.allUnique (extractLocalAddrs cfg.local);
          message = ''
            nix-bore: Detected duplicate values for bore local
            `local-addr:local-port` tuples in `services.bore.local`. Ensure
            these tuples are unique across instances! 

            (To turn off this assertion, set `services.bore.skipLocalPortCheck = true;`)
          '';
        })

        (lib.mkIf (!cfg.skipServerPortCheck) {
          assertion = lib.allUnique (extractRemoteAddrs cfg.servers);
          message = ''
            nix-bore: Detected duplicate values for bore remote `bind-addr`s
            in `services.bore.servers`. Ensure `bind-addr` is unique across servers! 

            (To turn off this assertion, set `services.bore.skipServerPortCheck = true;`)
          '';
        })
      ];
    };
}

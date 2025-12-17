{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types optionalString;
  cfg = config.services.bore;
in
{
  options = {
    services.bore.servers = mkOption {
      type = types.attrsOf (
        types.submodule {
          imports = [ ./options.nix ];
        }
      );
      default = { };
    };
  };

  config =
    let
      enabledServices = lib.filterAttrs (_: v: v.enable) cfg.servers;
    in
    {
      systemd.services = lib.mapAttrs' (name: value: {
        name = "bore-server-${name}";
        value = {
          description = "bore remote proxy service for ${name}";
          enable = true;
          after = [
            "network-online.target"
            "nss-lookup.target"
          ];

          requires = [
            "network-online.target"
            "nss-lookup.target"
          ];

          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            ExecStart = ''
              ${lib.getExe' cfg.package "bore"} server \
              --min-port ${builtins.toString value.min-port} \
              --max-port ${builtins.toString value.max-port} \
              ${optionalString (value.secret != null) "--secret ${value.secret} \ "}
              --bind-addr ${value.bind-addr} \
              --bind-tunnels ${value.bind-tunnels}
            '';
            Restart = "on-failure";
            RestartSec = 10;
          };
        };

      }) enabledServices;
    };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.services.bore;
  inherit (lib) mkOption types optionalString;
  inherit (types) attrsOf submodule;
in
{
  options = {
    services.bore.servers = mkOption {
      type = attrsOf (submodule {
        imports = [ ./options.nix ];
      });
      description = "Definition of bore remote proxy servers.";
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

          environment = {
            BORE_MIN_PORT = builtins.toString value.min-port;
            BORE_MAX_PORT = builtins.toString value.max-port;
          };

          script = ''
            ${optionalString (value.secretFile != null) ''export BORE_SECRET="$(<${value.secretFile})"''}

            ${lib.getExe' cfg.package "bore"} server --bind-addr="${value.bind-addr}" --bind-tunnels="${value.bind-tunnels}"
          '';

          serviceConfig = {
            Restart = "on-failure";
            RestartSec = 10;
          };
        };

      }) enabledServices;
    };
}

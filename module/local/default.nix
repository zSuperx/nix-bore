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
    services.bore.local = mkOption {
      type = attrsOf (submodule {
        imports = [ ./options.nix ];
      });
      description = "Definition of bore local proxies.";
      default = { };
    };
  };

  config =
    let
      enabledServices = lib.filterAttrs (_: v: v.enable) cfg.local;
    in
    {
      systemd.services = lib.mapAttrs' (name: value: {
        name = "bore-local-${name}";
        value = {
          description = "bore local proxy service for ${name}";
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
            BORE_SERVER = value.to;
            BORE_LOCAL_PORT = builtins.toString value.local-port;
          };

          script = ''
            ${optionalString (value.secretFile != null) ''export BORE_SECRET="$(<${value.secretFile})"''}

            ${lib.getExe' cfg.package "bore"} local --local-host="${value.local-host}" --port=${builtins.toString value.remote-port}
          '';

          serviceConfig = {
            Restart = "on-failure";
            RestartSec = 10;
          };
        };

      }) enabledServices;
    };
}

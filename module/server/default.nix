{
  config,
  lib,
  pkgs,
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
      default = { };
    };
  };

  config =
    let
      enabledServices = lib.filterAttrs (_: v: v.enable) cfg.servers;
    in
    {
      systemd.services = lib.mapAttrs' (
        name: value:
        let
          secret =
            if value.secretFile != null then
              "--secret ${value.secret}"
            else if value.secret != null then
              "--secret $(cat ${value.secretFile})"
            else
              "";
        in
        {
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
                ${secret} \
                --bind-addr ${value.bind-addr} \
                --bind-tunnels ${value.bind-tunnels}
              '';
              Restart = "on-failure";
              RestartSec = 10;
            };
          };

        }
      ) enabledServices;
    };
}

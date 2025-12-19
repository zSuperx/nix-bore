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
      default = { };
    };
  };

  config =
    let
      enabledServices = lib.filterAttrs (_: v: v.enable) cfg.local;
    in
    {
      systemd.services = lib.mapAttrs' (
        name: value:
        let
          args = builtins.concatStringsSep " " [
            "local"
            "--local-host ${value.local-host}"
            "--to ${value.to}"
            "--port ${builtins.toString value.remote-port}"
            "${optionalString (value.secret != null) "--secret $(cat ${value.secret})"}"
            "${builtins.toString value.local-port}"
          ];
        in
        {
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

            serviceConfig = {
              ExecStart = ''
                ${lib.getExe' cfg.package "bore"} ${args}
              '';
              Restart = "on-failure";
              RestartSec = 10;
            };
          };

        }
      ) enabledServices;
    };
}

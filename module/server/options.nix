{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options = {
    enable = mkEnableOption "Bore TCP tunnel (remote proxy server) for `<name>`";

    min-port = mkOption {
      type = types.int;
      default = 1024;
      description = ''
        Minimum accepted TCP port number.
      '';
    };

    max-port = mkOption {
      type = types.int;
      default = 65535;
      description = ''
        Maximum accepted TCP port number.
      '';
    };

    secret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Optional secret for authentication.
      '';
    };

    bind-addr = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = ''
        IP address to bind to, clients must reach this.
      '';
    };

    bind-tunnels = mkOption {
      type = types.str;
      default = config.bind-addr;
      description = ''
        IP address where tunnels will listen on, defaults to value of
        `services.bore.servers.<name>.bind-addr`.
      '';
    };
  };
}

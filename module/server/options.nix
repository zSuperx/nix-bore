{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;
  inherit (types)
    port
    nullOr
    str
    path
    ;
in
{
  options = {
    enable = mkEnableOption "Bore TCP tunnel (remote proxy server) for `<name>`";

    min-port = mkOption {
      type = port;
      default = 1024;
      description = ''
        Minimum accepted TCP port number.
      '';
    };

    max-port = mkOption {
      type = port;
      default = 65535;
      description = ''
        Maximum accepted TCP port number.
      '';
    };

    secretFile = mkOption {
      type = nullOr path;
      default = null;
      description = ''
        Optional path to file containing secret for authentication. 
      '';
    };

    bind-addr = mkOption {
      type = str;
      default = "0.0.0.0";
      description = ''
        IP address to bind to, clients must reach this.
      '';
    };

    bind-tunnels = mkOption {
      type = str;
      default = config.bind-addr;
      description = ''
        IP address where tunnels will listen on, defaults to value of
        `services.bore.servers.<name>.bind-addr`.
      '';
    };
  };
}

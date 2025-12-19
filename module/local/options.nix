{
  lib,
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
    enable = mkEnableOption "Bore TCP tunnel (local proxy to the remote server) for `<name>`";

    local-host = mkOption {
      type = str;
      default = "localhost";
      description = ''
        The local host to expose [default: localhost]
      '';
    };

    to = mkOption {
      type = str;
      default = "bore.pub";
      description = ''
        Address of the remote server to expose local ports to.
      '';
    };

    secretFile = mkOption {
      type = nullOr path;
      default = null;
      description = ''
        Optional path to file containing secret for authentication. 
      '';
    };

    remote-port = mkOption {
      type = port;
      default = 0;
      description = ''
        Optional port on the remote server to select. (If set to 0, a random
        available port will be assigned by the remote server.)
      '';
    };

    local-port = mkOption {
      type = port;
      description = ''
        The local port to expose.
      '';
    };
  };
}

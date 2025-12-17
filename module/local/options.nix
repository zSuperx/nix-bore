{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkEnableOption types;
  inherit (types) int nullOr str;
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

    secret = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Optional secret for authentication.
      '';
    };

    remote-port = mkOption {
      type = int;
      default = 0;
      description = ''
        Optional port on the remote server to select. (If set to 0, a random
        port will be assigned on the remote server.)
      '';
    };

    local-port = mkOption {
      type = int;
      description = ''
        The local port to expose.
      '';
    };
  };
}

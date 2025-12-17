# nix-bore

A flake that exposes a NixOS module for the Bore TCP proxy tunnel.

## Example Usage

There are 2 ways to run the `bore` program--server mode and local mode. Both
are supported by this NixOS module, and can be set up like so.

First add the module to your flake's inputs and import it from within the module system.
```nix
{
  inputs = {
    # ...
    nix-bore.url = "github:zSuperx/nix-bore";
  };

  outputs =
    { nixpkgs, nix-bore, ... }: # Add to inputs
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import module
          nix-bore.nixosModules.bore
        ];
      };
    };
}
```

### Local

```nix
# Bore local examples
{
  services.bore = {
    local = {
      minecraft = {
        enable = true;
        to = "mc.piyush.ai";
        remote-port = 6969;
        local-port = 6969;
        secret = "bobby";
      };

      other-thing = {
        enable = false;
        to = "bore.pub";
        local-port = 6969;
      };
    };
  };
}
```

The above code starts a single systemd service running `bore local`, catching
remotely forwared traffic from `mc.piyush.ai`, on local port `6969`.

### Server

```nix
# Bore server examples
{
  services.bore.servers = {
    remote-proxy = {
      enable = true;
      secret = "bobby";
    };

    remote-proxy2 = {
      enable = true;
    };
  };
}
```

The above code attempts to start 2 systemd services running `bore server`. It
will fail because **only one** `bore server` program can bind to `0.0.0.0` at a
time. A build-time assertion will be thrown in this case.


### Troubleshooting

Each enabled `services.bore.local.<name>` will result in a systemd service
under the name `bore-local-<name>.service`.

Likewise, each enabled `services.bore.servers.<name>` will result in a systemd
service under the name `bore-server-<name>.service`.

These can all be started and stopped with `systemctl [start|stop]
<service-name>`, and their logs can be observed with `journalctl -u
<service-name>`.

Additionally, `nix-bore` will run some basic address + port exclusivity assertions at
build time, warning you about any duplicate local address + port tuples and
remote addresses.

To disable these assertions, set `services.bore.skipLocalPortCheck` and/or
`services.bore.skipServerPortCheck` to `true`, but beware that the bore
services may silently fail on rebuild.


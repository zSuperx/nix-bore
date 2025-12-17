{ pkgs, ... }:
{
  services.bore.servers = {
    minecraft-proxy = {
      enable = true;
      secret = "bobby";
      bind-addr = "zenith";
    };

    minecraft-proxy2 = {
      enable = true;
      secret = "bobby";
      bind-addr = "zenith";
    };
  };
}

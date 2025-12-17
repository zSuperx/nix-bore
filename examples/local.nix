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
        local-port = 6970;
      };
    };
  };
}

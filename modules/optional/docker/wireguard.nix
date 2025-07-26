{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."wireguard" = {
    image = "linuxserver/wireguard:latest";
    autoStart = true;
    pull = "always";
    log-driver = "journald";
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Europe/Madrid";
      LOG_CONFS = "true";
    };
    volumes = [
      "wireguard:/config"
      "/lib/modules:/lib/modules:ro"
    ];
    #networks = ["main-network"];
    extraOptions = [
      "--network=host"
    ];
    capabilities = {
      NET_ADMIN = true;
      SYS_MODULE = true;
    };
  };

  boot.kernelModules = [
    "iptable_raw"
  ];
}



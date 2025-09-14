{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."kavita" = {
    image = "lscr.io/linuxserver/kavita:latest";
    autoStart = true;
    pull = "always";
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Europe/Madrid";
    };
    volumes = [
      "kavita:/config"
      "/mnt/storage/media/manga:/data/manga"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.23"
    ];
  };
}



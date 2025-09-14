{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "lscr.io/linuxserver/jellyfin:latest";
    autoStart = true;
    pull = "always";
    environment = {
      PUID = "1001";
      PGID = "1001";
      TZ = "Europe/Madrid";
      JELLYFIN_PublishedServerUrl = "https://jellyfin.networkrain.net";
    };
    volumes = [
      "jellyfin:/config"
      "/export/storage/media/shows:/data/shows"
      "/export/storage/media/movies:/data/movies"
      "/export/storage/media/anime:/data/anime"
    ];
    devices = [
      "/dev/dri/card0:/dev/dri/card0"
      "/dev/dri/card1:/dev/dri/card1"
      "/dev/dri/renderD128:/dev/dri/renderD128"
    ];
    ports = [
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.22"
    ];
  };
}



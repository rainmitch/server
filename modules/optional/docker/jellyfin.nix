{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "lscr.io/linuxserver/jellyfin:latest";
    autoStart = true;
    pull = "always";
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Europe/Madrid";
      JELLYFIN_PublishedServerUrl = "https://jellyfin.networkrain.net";
    };
    volumes = [
      "jellyfin:/config"
      "/mnt/storage/media/shows:/data/shows"
      "/mnt/storage/media/movies:/data/movies"
      "/mnt/storage/media/anime:/data/anime"
    ];
    ports = [
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.22"
    ];
  };
}



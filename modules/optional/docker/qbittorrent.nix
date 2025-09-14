{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."qbittorrent" = {
    image = "lscr.io/linuxserver/qbittorrent:latest";
    autoStart = true;
    pull = "always";
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Europe/Madrid";
      WEBUI_PORT = "8080";
      TORRENTING_PORT = "60053";
    };
    volumes = [
      "qbittorrent:/config"
      "/tmp/downloads:/downloads"
      "/mnt/storage/torrents:/torrents"
    ];
    #networks = ["main-network"];
    extraOptions = [
      "--network=host"
    ];
  };
}



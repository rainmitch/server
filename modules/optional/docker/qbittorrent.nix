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
      ""
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.14"
    ];
  };
}



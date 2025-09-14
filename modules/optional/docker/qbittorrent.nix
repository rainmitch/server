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
<<<<<<< HEAD
      "/tmp/incomplete:/incomplete"
=======
      "/tmp/downloads:/downloads"
      "/mnt/storage/torrents:/torrents"
>>>>>>> 6195fd094d9eebca9a14b916f7b70b2ba804d53a
    ];
    #networks = ["main-network"];
    extraOptions = [
      "--network=host"
    ];
  };
}



{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."adguardhome" = {
    image = "adguard/adguardhome:latest";
    autoStart = true;
    pull = "always";
    log-driver = "journald";
    environment = {
      
    };
    volumes = [
      "adguardWork:/opt/adguardhome/work"
      "adguardConf:/opt/adguardhome/conf"
    ];
    ports = [
      "53:53/tcp"
      "53:53/tcp"
      "8080:80/tcp"
      "8443:443/tcp"
      "853:853/tcp"
      "853:853/udp"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.8"
    ];
  };
}



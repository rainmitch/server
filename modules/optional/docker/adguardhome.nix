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
      #"3001:3000/tcp"
      #"127.0.0.1:8080:80/tcp"
      #"127.0.0.1:8443:443/tcp"
      #"127.0.0.1:853:853/tcp"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.8"
    ];
  };
}



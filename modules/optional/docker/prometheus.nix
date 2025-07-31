{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."prometheus" = {
    image = "prom/prometheus:latest";
    autoStart = true;
    pull = "always"; 
    environment = { 
       
    };
    user = "1001:1001";
    volumes = [
        
    ];
    ports = [
      "127.0.0.1:9090/tcp"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.6"
    ];
  };
}

{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."vaultwarden" = {
    image = "vaultwarden/server:latest";
    autoStart = true;
    pull = "always";
    environment = {
      
    };
    volumes = [
      "vaultwarden:/data"
    ];
    ports = [
      "7080:80"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.9"
    ];
  };
}



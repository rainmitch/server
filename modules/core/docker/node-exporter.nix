{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."node-exporter" = {
    image = "bitnami/node-exporter:latest";
    autoStart = true;
    pull = "always";
    environment = {

    };
    volumes = [
      
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.15"
    ];
  };
}

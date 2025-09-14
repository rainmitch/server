
{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."prometheus" = {
    image = "bitnami/prometheus:latest";
    autoStart = true;
    pull = "always";
    environment = {

    };
    volumes = [
      "prometheus:/opt/bitnami/prometheus/data"
      "prometheus-conf:/opt/bitnami/prometheus/conf"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.6"
    ];
  };
}

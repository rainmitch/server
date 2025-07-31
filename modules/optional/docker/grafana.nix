{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."grafana" = {
    image = "grafana/grafana-oss:latest";
    autoStart = true;
    pull = "always";
    environment = {
      GF_LOG_LEVEL = "debug";
    };
    user = "1001:1001";
    volumes = [
      "grafana:/var/lib/grafana"
    ];
    ports = [
      "127.0.0.1:3000:3000/tcp"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.5"
    ];
  };
}



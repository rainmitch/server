{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."sillytavern" = {
    image = "ghcr.io/sillytavern/sillytavern:1.13.1";
    autoStart = true;
    pull = "always";
    environment = {
      node_env = "production";
      force_color = "1";
    };
    volumes = [
      "sillytavern:/home/node/app"
    ];
    ports = [
      "8102:8000/tcp"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.10"
    ];
  };
}



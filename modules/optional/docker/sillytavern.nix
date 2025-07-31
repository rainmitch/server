{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."sillytavern" = {
    image = "ghcr.io/sillytavern/sillytavern:latest";
    autoStart = true;
    pull = "always";
    environment = {
      node_env = "production";
      force_color = "1";
    };
    volumes = [
      "sillytavernConfig:/home/node/app/config"
      "sillytavernData:/home/node/app/data"
      "sillytavernPlugins:/home/node/app/plugins"
      "sillytavernExtensions:/home/node/app/public/scripts/extensions/third-party"
    ];
    ports = [
      #"127.0.0.1:8000:8000/tcp"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.20"
    ];
  };
}



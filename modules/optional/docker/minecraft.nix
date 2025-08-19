{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."minecraft-liminal" = {
    image = "itzg/minecraft-server:java21-graalvm";
    autoStart = true;
    pull = "always";
    environment = {
      EULA = "true";
      TZ = "Europe/Madrid";
      MAX_MEMORY = "6G";
      VERSION = "1.20.1";
      TYPE = "FORGE";
    };
    volumes = [
      "/servers/mc-liminal:/data"
    ];
    ports = [

    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.30"
    ];
  };
}



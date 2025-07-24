

{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."portainer" = {
    image = "portainer/agent:lts";
    autoStart = true;
    pull = "always";
    environment = {
      
    };
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/docker/volumes:/docker/volumes"
    ];
    ports = [
      "9001:9001/tcp"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.2"
    ];
  };
}

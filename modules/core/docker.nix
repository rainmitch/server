
{config, pkgs, ...}:

{
  imports = [
    ./docker/portainer.nix
  ];
  virtualisation.docker.enable = true;
  
  virtualisation.docker.daemon.settings = {
    data-root = "/docker";
    userland-proxy = false;
    experimental = true;
    metrics-addr = "0.0.0.0:9323";
    ipv6 = false;
    iptables = false;
  };
  virtualisation.oci-containers.backend = "docker";
  systemd.services.docker-custom-network = {
    description = "Create custom Docker network";
    # This service ensures the network exists before your containers start
    wantedBy = [ "multi-user.target" ];
    # Replace 'my-network' with your desired network name
    # Replace '172.18.0.0/24' with your desired subnet
    script = ''
      ${pkgs.docker}/bin/docker network inspect main-network > /dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create \
        --driver bridge \
        --subnet 172.18.0.0/24 \
        --gateway 172.18.0.1 \
        --opt "com.docker.network.bridge.name"="main0" \
        main-network
    '';
    # Ensures this service runs before any OCI containers that might depend on it
    before = [ "virtualisation-oci-containers.target" ];
    # This makes it a one-shot service, meaning it runs once and exits
    serviceConfig.Type = "oneshot";
    # This prevents it from failing if the network already exists
    serviceConfig.RemainAfterExit = true;
};
}

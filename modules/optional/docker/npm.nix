{config, pkgs, lib, ...}:

{
  virtualisation.oci-containers.containers."npm" = {
    image = "jc21/nginx-proxy-manager:latest";
    autoStart = true;
    pull = "always";
    log-driver = "journald";
    environment = {
      DISABLE_IPV6 = "true";
    };
    volumes = [
      "npm:/data"
      "/letsencrypt:/etc/letsencrypt"
    ];
    ports = [
      "80:80"
      "443:443"
      "81:81"
    ];
    networks = ["main-network"];
    extraOptions = [
      "--ip=172.18.0.4"
    ];
  };
}



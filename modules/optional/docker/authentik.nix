# This NixOS configuration converts your docker-compose setup for Authentik
# to use the oci-containers module.
#
# It defines each service (postgresql, redis, server, worker) as an OCI container,
# mapping their respective images, ports, volumes, environment variables,
# health checks, and commands.
#
# IMPORTANT: For sensitive data like passwords and secret keys,
# it is strongly recommended to use a secure secret management solution
# like 'sops-nix' in your actual NixOS configuration.
# The values provided here are placeholders or defaults from your docker-compose.

{ config, pkgs, lib, ... }:

let
  authentikImage = "ghcr.io/goauthentik/server";
  authentikTag = "2025.6.4"; # Or your desired Authentik tag
  #composePortHttp = "9000"; # Default HTTP port for Authentik
  #composePortHttps = "9443"; # Default HTTPS port for Authentik

  # Base directory on the NixOS host for Authentik's persistent data
  #authentikDataDir = "/var/lib/authentik";

in
{
  # --- Define individual OCI containers ---
  virtualisation.oci-containers.containers = {
    # --- PostgreSQL Service ---
    "authentik-postgresql" = {
      image = "docker.io/library/postgres:16-alpine";
      autoStart = true; # Equivalent to restart: unless-stopped for initial start
      # Docker-specific restart policy and health checks are passed via extraOptions
      extraOptions = [
        #"--health-cmd=pg_isready -d ${pgDb} -U ${pgUser}"
        #"--health-start-period=20s"
        #"--health-interval=30s"
        #"--health-retries=5"
        #"--health-timeout=5s"
        "--ip=172.18.0.12"
      ];
      # Volume mapping: hostPath:containerPath
      volumes = [
        "authentik-postgres:/var/lib/postgresql/data"
      ];
      environmentFiles = [
        config.sops.secrets."authentik.env".path
      ];
      networks = ["main-network"];
    };

    # --- Redis Service ---
    "authentik-redis" = {
      image = "docker.io/library/redis:alpine";
      autoStart = true;
      extraOptions = [
        "--health-cmd=redis-cli ping | grep PONG"
        "--health-start-period=20s"
        "--health-interval=30s"
        "--health-retries=5"
        "--health-timeout=3s"
        "--ip=172.18.0.13"
      ];
      volumes = [
        "authentik-redis:/data"
      ];
      networks = ["main-network"];
      # Command to run inside the Redis container
      cmd = [ "--save" "60" "1" "--loglevel" "warning" ];
    };

    # --- Authentik Server Service ---
    "authentik-server" = {
      image = "${authentikImage}:${authentikTag}";
      autoStart = true;
      extraOptions = [
        "--ip=172.18.0.10"
      ];
      cmd = [ "server" ]; # Command to run for the server
      environment = {
        AUTHENTIK_REDIS__HOST = "172.18.0.13"; # Refers to the internal container name for Redis
        AUTHENTIK_POSTGRESQL__HOST = "172.18.0.12"; # Refers to the internal container name for PostgreSQL
      };
      environmentFiles = [
        config.sops.secrets."authentik.env".path
      ];
      volumes = [
        "authentik-server-media:/media"
        "authentik-server-templates:/templates"
      ];
      networks = ["main-network"];
      
      # `depends_on` is implicitly handled by oci-containers.
      # Containers will attempt to start, and if a dependency (like a healthy DB)
      # is not met, the container will restart until it is.
    };

    # --- Authentik Worker Service ---
    "authentik-worker" = {
      image = "${authentikImage}:${authentikTag}";
      autoStart = true;
      extraOptions = [
        "--ip=172.18.0.11"
      ];
      cmd = [ "worker" ]; # Command to run for the worker
      environment = {
        AUTHENTIK_REDIS__HOST = "172.18.0.13";
        AUTHENTIK_POSTGRESQL__HOST = "172.18.0.12";
      };
      environmentFiles = [
        config.sops.secrets."authentik.env".path
      ];
      user = "root"; # As specified in the docker-compose for docker socket access
      volumes = [
        # Mount the Docker socket for the worker to interact with Docker daemon
        "/var/run/docker.sock:/var/run/docker.sock"
        "authentik-worker-media:/media"
        "authentik-worker-certs:/certs"
        "authentik-worker-templates:/templates"
      ];
      networks = ["main-network"];
      # `depends_on` is implicitly handled as for the 'server' service.
    };
  };
}

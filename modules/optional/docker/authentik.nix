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
  # --- Configuration Variables ---
  # Define these variables. For sensitive data, replace the hardcoded strings
  # with references to your secret management system (e.g., config.sops.secrets.<name>.path).
  # Example: pgPass = builtins.readFile config.sops.secrets.authentik_pg_pass.path;
  pgPass = "your_strong_database_password"; # <<< IMPORTANT: CHANGE THIS!
  pgUser = "authentik";
  pgDb = "authentik";
  authentikSecretKey = "your_long_random_secret_key_for_authentik"; # <<< IMPORTANT: CHANGE THIS!
  authentikImage = "ghcr.io/goauthentik/server";
  authentikTag = "2025.6.4"; # Or your desired Authentik tag
  composePortHttp = "9000"; # Default HTTP port for Authentik
  composePortHttps = "9443"; # Default HTTPS port for Authentik

  # Base directory on the NixOS host for Authentik's persistent data
  authentikDataDir = "/var/lib/authentik";

in
{
  # --- Enable the oci-containers module ---
  virtualisation.oci-containers.enable = true;

  # --- Ensure host directories for volumes exist ---
  # This creates the necessary directories on the host system where container
  # volumes will be mounted. These directories will persist data even if
  # containers are recreated.
  systemd.tmpfiles.rules = [
    "d ${authentikDataDir} 0755 root root -"
    "d ${authentikDataDir}/database 0755 root root -" # For PostgreSQL data
    "d ${authentikDataDir}/redis 0755 root root -"    # For Redis data
    "d ${authentikDataDir}/media 0755 root root -"    # For Authentik media files
    "d ${authentikDataDir}/custom-templates 0755 root root -" # For Authentik custom templates
    "d ${authentikDataDir}/certs 0755 root root -"    # For Authentik certificates
  ];

  # --- Define individual OCI containers ---
  virtualisation.oci-containers.containers = {

    # --- PostgreSQL Service ---
    postgresql = {
      image = "docker.io/library/postgres:16-alpine";
      autoStart = true; # Equivalent to restart: unless-stopped for initial start
      # Docker-specific restart policy and health checks are passed via extraOptions
      extraOptions = [
        "--restart=unless-stopped"
        "--health-cmd=pg_isready -d ${pgDb} -U ${pgUser}"
        "--health-start-period=20s"
        "--health-interval=30s"
        "--health-retries=5"
        "--health-timeout=5s"
      ];
      # Volume mapping: hostPath:containerPath
      volumes = [
        "${authentikDataDir}/database:/var/lib/postgresql/data"
      ];
      # Environment variables for PostgreSQL
      environment = {
        POSTGRES_PASSWORD = pgPass;
        POSTGRES_USER = pgUser;
        POSTGRES_DB = pgDb;
      };
    };

    # --- Redis Service ---
    redis = {
      image = "docker.io/library/redis:alpine";
      autoStart = true;
      extraOptions = [
        "--restart=unless-stopped"
        "--health-cmd=redis-cli ping | grep PONG"
        "--health-start-period=20s"
        "--health-interval=30s"
        "--health-retries=5"
        "--health-timeout=3s"
      ];
      volumes = [
        "${authentikDataDir}/redis:/data"
      ];
      # Command to run inside the Redis container
      cmd = [ "--save" "60" "1" "--loglevel" "warning" ];
    };

    # --- Authentik Server Service ---
    server = {
      image = "${authentikImage}:${authentikTag}";
      autoStart = true;
      extraOptions = [
        "--restart=unless-stopped"
      ];
      cmd = [ "server" ]; # Command to run for the server
      environment = {
        AUTHENTIK_SECRET_KEY = authentikSecretKey;
        AUTHENTIK_REDIS__HOST = "redis"; # Refers to the internal container name for Redis
        AUTHENTIK_POSTGRESQL__HOST = "postgresql"; # Refers to the internal container name for PostgreSQL
        AUTHENTIK_POSTGRESQL__USER = pgUser;
        AUTHENTIK_POSTGRESQL__NAME = pgDb;
        AUTHENTIK_POSTGRESQL__PASSWORD = pgPass;
      };
      volumes = [
        "${authentikDataDir}/media:/media"
        "${authentikDataDir}/custom-templates:/templates"
      ];
      # Port mapping: hostPort:containerPort
      ports = [
        "${composePortHttp}:9000"
        "${composePortHttps}:9443"
      ];
      # `depends_on` is implicitly handled by oci-containers.
      # Containers will attempt to start, and if a dependency (like a healthy DB)
      # is not met, the container will restart until it is.
    };

    # --- Authentik Worker Service ---
    worker = {
      image = "${authentikImage}:${authentikTag}";
      autoStart = true;
      extraOptions = [
        "--restart=unless-stopped"
      ];
      cmd = [ "worker" ]; # Command to run for the worker
      environment = {
        AUTHENTIK_SECRET_KEY = authentikSecretKey;
        AUTHENTIK_REDIS__HOST = "redis";
        AUTHENTIK_POSTGRESQL__HOST = "postgresql";
        AUTHENTIK_POSTGRESQL__USER = pgUser;
        AUTHENTIK_POSTGRESQL__NAME = pgDb;
        AUTHENTIK_POSTGRESQL__PASSWORD = pgPass;
      };
      user = "root"; # As specified in the docker-compose for docker socket access
      volumes = [
        # Mount the Docker socket for the worker to interact with Docker daemon
        "/var/run/docker.sock:/var/run/docker.sock"
        "${authentikDataDir}/media:/media"
        "${authentikDataDir}/certs:/certs"
        "${authentikDataDir}/custom-templates:/templates"
      ];
      # `depends_on` is implicitly handled as for the 'server' service.
    };
  };
}

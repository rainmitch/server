# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

# Blackview config

{
  sops.defaultSopsFile = ../secrets/blackview.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets."authentik/pgPass" = {};
  sops.secrets."authentik/pgUser" = {};
  sops.secrets."authentik/pgDb" = {};
  sops.secrets."authentik/authentikSecretKey" = {};
  imports = [ # Include the results of the hardware scan.
      ./hardware/blackview.nix
      ../modules/optional/network/blackview.nix
      ../modules/optional/firewall/blackview.nix      

      # Docker services
      ../modules/optional/docker/npm.nix
      ../modules/optional/docker/wireguard.nix
      ../modules/optional/docker/adguardhome.nix
      ../modules/optional/docker/vaultwarden.nix
      ../modules/optional/docker/sillytavern.nix
      ../modules/optional/docker/grafana.nix
  ];
  
  environment.systemPackages = [
    pkgs.openssl
  ];
  
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}


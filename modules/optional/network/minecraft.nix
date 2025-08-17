
{ config, lib, pkgs, ... }:

{
  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.0.24";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "ens18";
    };
    nameservers = [ "1.1.1.1" ];
    hostName = "minecraft";
    enableIPv6 = false;
  };
}

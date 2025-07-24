
{ config, lib, pkgs, ... }:

{
  networking = {
    interfaces = {
      end0.ipv4.addresses = [{
        address = "192.168.0.9";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "end0";
    };
    nameservers = [ "1.1.1.1" ];
    hostName = "pi";
    enableIPv6 = false;
  };
}

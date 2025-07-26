
{ config, lib, pkgs, ... }:

{
  networking = {
    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.0.9";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "ens18";
    };
    nameservers = [ "1.1.1.1" ];
    hostName = "blackview";
    enableIPv6 = false;
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.src_valid_mark" = 1;
  };
}


{ config, lib, pkgs, ... }:

{
  services.vsftpd = {
    enable = true;
    localUsers = true;
    writeEnable =  true;
    extraConfig = ''
      pasv_min_port=50000
      pasv_max_port=50010
    '';
  };
}

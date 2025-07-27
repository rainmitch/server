
{config, pkgs, lib, ...}:


let 
  hostname = lib.strings.trim (builtins.readFile /etc/hostname);
in {
  imports = [
    (./configurations + "/${hostname}.nix")
  ];
}

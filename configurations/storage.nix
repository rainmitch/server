
{config, ...}:

{
  imports = [
    ./hardware/storage.nix
    ./default-config.nix
    ../modules/optional/nfs/storage.nix    
    ../modules/optional/network/storage.nix 
    ../modules/optional/firewall/storage.nix
  ];
}


{config, ...}:

{
  imports = [
    ./default-config.nix
    ../modules/optional/nfs/storage.nix    
    ../modules/optional/network/storage.nix 
    ../modules/optional/firewall/storage.nix
  ];
}

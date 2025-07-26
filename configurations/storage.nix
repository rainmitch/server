
{config, ...}:

{
  imports = [
    ./hardware/vm.nix
    ./default-config.nix
    ../modules/optional/nfs/storage.nix    
    ../modules/optional/network/storage.nix 
    ../modules/optional/firewall/storage.nix
  ];
  
  fileSystems."/mnt/storage" =
  {
    device = "/dev/disk/by-uuid/d585b373-eae5-41c2-9269-d7a36a217004";
    fsType= "ext4";
  };

  fileSystems."/mnt/docker" =
  {
    device = "/dev/disk/by-uuid/16540d33-e787-45c0-99c8-53c6865a1342";
    fsType = "ext4";
  };

}


{config, ...}:

{
  imports = [
    ./hardware/vm.nix
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

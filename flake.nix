

{
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, sops-nix }: {
    # change `yourhostname` to your actual hostname
    nixosConfigurations.blackview = nixpkgs.lib.nixosSystem {
      # customize to your system
      system = "x86_64-linux";
      modules = [
        ./configurations/blackview.nix
        sops-nix.nixosModules.sops
      ];
    };
    nixosConfigurations.storage = nixpkgs.lib.nixosSystem {
      # customize to your system
      system = "x86_64-linux";
      modules = [
        ./configurations/storage.nix
        sops-nix.nixosModules.sops
      ];
    };
  };
}

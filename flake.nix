
{
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, sops-nix }: {
    # change `yourhostname` to your actual hostname
    nixosConfigurations.blackview = nixpkgs.lib.nixosSystem {
      # customize to your system
      system = "x86_64-linux";
      modules = [
        ./configurations/common.nix
        ./configurations/blackview.nix
        sops-nix.nixosModules.sops
      ];
    };
    nixosConfigurations.storage = nixpkgs.lib.nixosSystem {
      # customize to your system
      system = "x86_64-linux";
      modules = [
        ./configurations/common.nix
        ./configurations/storage.nix
        sops-nix.nixosModules.sops
      ];
    };
    nixosConfigurations.privacy = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configurations/common.nix
        ./configurations/privacy.nix
      ];
    };
    nixosConfigurations.minecraft = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configurations/common.nix
        ./configurations/minecraft.nix
      ];
    };
  };
}

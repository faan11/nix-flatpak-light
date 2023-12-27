{
  description = "Flatpak Management Flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    modules = {
      flatpak = { import ./src/flatpakModule.nix;}
    };
  };
}

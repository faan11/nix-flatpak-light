{
  description = "Flatpak Management Flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    modules = {
      flatpakModule = {
        description = "Module for managing Flatpak packages";
        path = ./src/flatpakModule.nix;
      };
    };
  };
}

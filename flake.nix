{
  description = "Manage flatpak apps declaratively.";
  outputs = _: {
    modules = {
      flatpak = import ./src/flatpakModule.nix;
    };
  };
}

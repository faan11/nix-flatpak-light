{
  outputs = _: {
    modules = {
      flatpak = { import ./src/flatpakModule.nix;}
    };
  };
}

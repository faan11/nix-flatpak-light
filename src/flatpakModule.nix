{ lib, pkgs, ... }:

let
  options = {
    allowFlatpak = {
      default = false;
      type = types.bool;
      description = "Enable Flatpak support";
    };

    flatpakPackages = {
      default = [];
      type = types.listOf (types.attrsOf types.str);
      description = "List of Flatpak packages to install/update";
    };
    
    flatpakRemotes = {
      default = [];
      type = types.listOf types.string;
      description = "List of Flatpak remotes";
    };
  };

in {
  options = options;

  config = { config, lib, pkgs, ... }:

  if config.allowFlatpak then {
    services.flatpak = {
      enable = true;
      extraRemotes = config.flatpakRemotes;
    };

    # Function to install/update Flatpak packages and set permissions
    programs.flatpak = {
      enable = true;
      packages = map (pkg: pkgs.flatpakPackages."${pkg.name}" or pkgs.flatpakPackages.${pkg.name}) config.flatpakPackages;

      postInstall = ''
        for p in ${config.flatpakPackages}; do
          flatpak install -y $p.repo $p.name
          flatpak override --$p.user --app $p.name --$p.permissions
        done
      '';

      postUpdate = ''
        for p in ${config.flatpakPackages}; do
          flatpak update -y $p.name
          flatpak override --$p.user --app $p.name --$p.permissions
        done
      '';
    };
  } else {};
}

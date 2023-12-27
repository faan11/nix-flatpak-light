{ lib, pkgs, config, ... }@args:
let
  types = args.types;

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

  enableFlatpak = args.config.allowFlatpak && args.config.flatpakPackages != [] && args.config.flatpakRemotes != [];

in
{
  options = options;

  config = if enableFlatpak then {
    services.flatpak = {
      enable = true;
      extraRemotes = args.config.flatpakRemotes;
    };

    # Function to install/update Flatpak packages and set permissions
    programs.flatpak = {
      enable = true;
      packages = map (pkg: pkgs.flatpakPackages."${pkg.name}" or pkgs.flatpakPackages.${pkg.name}) args.config.flatpakPackages;

      postInstall = ''
        for p in ${args.config.flatpakPackages}; do
          flatpak install -y $p.repo $p.name
          flatpak override --$p.user --app $p.name --$p.permissions
        done
      '';

      postUpdate = ''
        for p in ${args.config.flatpakPackages}; do
          flatpak update -y $p.name
          flatpak override --$p.user --app $p.name --$p.permissions
        done
      '';
    };
  } else {};
}

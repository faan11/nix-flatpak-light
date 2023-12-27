{ lib, pkgs, types, ... }@args:
let
  options = {
    allowFlatpak = {
      default = false;
      type = args.types.bool;
      description = "Enable Flatpak support";
    };

    flatpakPackages = {
      default = [];
      type = args.types.listOf (args.types.attrsOf args.types.str);
      description = "List of Flatpak packages to install/update";
    };
    
    flatpakRemotes = {
      default = [];
      type = args.types.listOf args.types.string;
      description = "List of Flatpak remotes";
    };
  };

in {
  options = options;

  config = mkIf args.config.allowFlatpak && has args.config.flatpakPackages && has args.config.flatpakRemotes then {
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

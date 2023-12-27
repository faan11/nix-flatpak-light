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

  enableFlatpak = config.allowFlatpak && config.flatpakPackages != [] && config.flatpakRemotes != [];

  flatpakConfig = if enableFlatpak then {
    services.flatpak = {
      enable = true;
      extraRemotes = config.flatpakRemotes;
    };

    # Function to install/update Flatpak packages and set permissions
    programs.flatpak = {
      enable = true;
      packages = map (pkg: pkgs.flatpakPackages."${pkg.name}" or pkgs.flatpakPackages.${pkg.name}) config.flatpakPackages;

      postInstall = ''
        + lib.concatMapStringsSep " && " (pkg: ''
          "${pkgs.flatpak}"/bin/flatpak install -y "${pkg.repo}" "${pkg.name}"
          "${pkgs.flatpak}"/bin/flatpak override --user="${pkg.user}" --app="${pkg.name}" -- "${pkg.permissions}"
        '') config.flatpakPackages;

      postUpdate = ''
        + lib.concatMapStringsSep " && " (pkg: ''
          "${pkgs.flatpak}"/bin/flatpak update -y "${pkg.name}"
          "${pkgs.flatpak}"/bin/flatpak override --user="${pkg.user}" --app="${pkg.name}" -- "${pkg.permissions}"
        '') config.flatpakPackages;
    };
  } else {};

in {
  options = options;
  config = flatpakConfig;
}

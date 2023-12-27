{ config, lib, pkgs, ... }:

{
  options = {
    allowFlatpak = mkOption {
      default = false;
      type = types.bool;
      description = "Enable Flatpak support";
    };

    flatpakPackages = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "List of Flatpak packages to install/update";
    };
    
    flatpakRemotes = mkOption {
      type = types.listOf types.string;
      default = [];
      description = "List of Flatpak remotes";
    };
  };

  config = if config.allowFlatpak then {
    services.flatpak = {
      enable = true;
      extraRemotes = config.flatpakRemotes;
    };

    # Function to install/update Flatpak packages and set permissions
    programs.flatpak = {
      enable = true;
      packages = map (pkg: pkgs.flatpakPackages."${pkg.name}" or pkgs.flatpakPackages.${pkg.name}) config.flatpakPackages;

      postInstall = ''
        for package in ${config.flatpakPackages}; do
          flatpak install -y ${package.repo} ${package.name}
          flatpak override --${package.user} --app ${package.name} --${package.permissions}
        done
      '';

      postUpdate = ''
        for package in ${config.flatpakPackages}; do
          flatpak update -y ${package.name}
          flatpak override --${package.user} --app ${package.name} --${package.permissions}
        done
      '';
    };
  } else {};
}

{ ... }: {
  setPermissions = packageName: permissions: ''
    flatpak override --user --app ${packageName} --${permissions}
  '';
}

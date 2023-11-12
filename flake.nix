{
  inputs.nixpkgs-lib.url = "github:nixos/nixpkgs/nixos-23.05?dir=lib";

  outputs = { self, nixpkgs-lib }:
    let
      lib = nixpkgs-lib.lib;
    in
    {
      lib.packagesFromVersionsFile =

        { versionsFile
        , system ? builtins.currentSystem
        , plugins ? { }
        , skipMissingPlugins ? false
        }:
        let
          fileLines = file: lib.splitString "\n" (lib.fileContents file);
          removeComments = builtins.filter (line: !lib.hasPrefix "#" line);
          parseVersions = builtins.map
            (line:
              let
                pluginAndVersion = builtins.split " " line;
              in
              {
                name = builtins.elemAt pluginAndVersion 0;
                value = builtins.elemAt pluginAndVersion 2;
              });
          filterPlugins = builtins.filter
            ({ name, ... }:
              let
                hasPlugin = builtins.hasAttr name plugins;
              in
              lib.throwIf (!skipMissingPlugins && !hasPlugin)
                ''
                  No plugin found for "${name}", try adding the missing plugin:

                  ```
                  asdf2nix.lib.packagesFromToolVersions = {
                    plugins = {
                      ${name} = asdf-${name}.lib.packageFromVersion;
                      ...
                    };
                    ...
                  };
                  ```

                  Or enable `skipMissingPlugins` to skip this error:

                  ```
                  asdf2nix.lib.packagesFromToolVersions = {
                    plugins = { ... };
                    skipMissingPlugins = true;
                    ...
                  };
                  ```
                ''
                hasPlugin);
          findPackage = plugin: version: plugins.${plugin} {
            inherit system version;
          };
        in
        builtins.mapAttrs findPackage
          (builtins.listToAttrs
            (filterPlugins
              (parseVersions
                (removeComments
                  (fileLines versionsFile)))));
    };
}

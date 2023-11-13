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
                pluginAndVersion = lib.splitString " " line;
              in
              {
                name = builtins.elemAt pluginAndVersion 0;
                value = builtins.elemAt pluginAndVersion 1;
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
                  <asdf2nix>.lib.packagesFromVersionsFile {
                    plugins = {
                      ${name} = asdf2nix-${name}.lib.packageFromVersion;
                      ...
                    };
                    ...
                  };
                  ```

                  Or enable `skipMissingPlugins` to skip this error:

                  ```
                  <asdf2nix>.lib.packagesFromVersionsFile {
                    plugins = { ... };
                    skipMissingPlugins = true;
                    ...
                  };
                  ```
                ''
                lib.warnIf
                (!hasPlugin) "Skipping \"${name}\" plugin"
                hasPlugin);
          findPackages = builtins.mapAttrs
            (name: version:
              let
                plugin = plugins.${name};
              in
              lib.throwIf (!plugin.hasVersion { inherit system version; }) ''
                Plugin "${name}" does not provide version "${version}", try
                updating the plugin's input:

                ```
                > nix flake lock --update-input <asdf2nix-${name}>
                ```
              ''
                plugin.packageFromVersion
                { inherit system version; });
        in
        findPackages
          (builtins.listToAttrs
            (filterPlugins
              (parseVersions
                (removeComments
                  (fileLines versionsFile)))));
    };
}

{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [ pkgs.nodejs ];
          };
        })
    //
    (
      let
        lib = nixpkgs.lib;
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
                  version = builtins.elemAt pluginAndVersion 1;
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
                        ${name} = <asdf2nix-${name}>.lib.packageFromVersion;
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
            findPackages = builtins.map
              ({ name, version }:
                let
                  plugin = plugins.${name};
                in
                lib.throwIf (!plugin.hasVersion { inherit system version; })
                  ''
                    Plugin "${name}" does not provide version "${version}", try
                    updating the plugin's input:

                    ```
                    > nix flake lock --update-input <asdf2nix-${name}>
                    ```
                  ''
                  {
                    inherit name;
                    value = plugin.packageFromVersion { inherit system version; };
                  }
              );
          in
          builtins.listToAttrs
            (findPackages
              (filterPlugins
                (parseVersions
                  (removeComments
                    (fileLines versionsFile)))));

        templates = {
          default = {
            description = "Install Nix packages from asdf versions file";
            path = ./templates/default;
          };
          devenv = {
            description = "Integration with devenv";
            path = ./templates/devenv;
          };
        };
      }
    );
}

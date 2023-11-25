{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05?dir=lib";

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
    in
    {
      lib.packagesFromVersionsFile =
        { versionsFile ? null
        , legacyVersionFiles ? { }
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
          toolVersions =
            if versionsFile == null
            then { }
            else
              builtins.listToAttrs
                (parseVersions
                  (removeComments
                    (fileLines versionsFile)));
          legacyVersions =
            builtins.mapAttrs
              (_: file: lib.fileContents file)
              legacyVersionFiles;
          versions =
            lib.throwIf (versionsFile == null && legacyVersionFiles == { })
              ''
                No version files provided. Try with `versionsFile`:

                ```
                packagesFromVersionsFile {
                  versionsFile = ./.tool-versions;
                  ...
                }
                ```

                Or `legacyVersionFiles`:

                ```
                packagesFromVersionsFile {
                  legacyVersionFiles = {
                    python = ./.python-version;
                  };
                  ...
                }
                ```
              ''
              toolVersions // legacyVersions;
          filterPlugins = lib.filterAttrs
            (name: _:
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
          findPackages = builtins.mapAttrs
            (name: version:
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
                plugin.packageFromVersion
                {
                  inherit system version;
                }
            );
        in
        findPackages (filterPlugins versions);

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
    };
}

{
  inputs.nixtest.url = "github:jetpack-io/nixtest";

  outputs = { self, nixtest }: {
    lib.packagesFromToolVersions =
      { toolVersions
      , system ? builtins.currentSystem
      , plugins ? { }
      , skipMissingPlugins ? false
      }:
      let
        mkVersion = rawVersion:
          let
            pluginAndVersion = builtins.split " " rawVersion;
          in
          {
            name = builtins.elemAt pluginAndVersion 0;
            value = builtins.elemAt pluginAndVersion 2;
          };
        mkPackage = plugin: version: plugins.${plugin} { inherit system version; };
        checkPlugin = { name, ... }:
          let
            hasPlugin = builtins.hasAttr name plugins;
          in
          if skipMissingPlugins
          then builtins.traceVerbose (if hasPlugin then "Plugin ${name} found" else "Skipping plugin ${name}") hasPlugin
          else hasPlugin || throw ''
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
          '';
        versions =
          builtins.listToAttrs
            (builtins.filter checkPlugin
              (builtins.map mkVersion
                (builtins.filter (x: x != [ ] && x != "")
                  (builtins.split "\n"
                    (builtins.readFile toolVersions)))));
      in
      builtins.mapAttrs mkPackage versions;

    tests = nixtest.run ./.;
  };
}

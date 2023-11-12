{
  outputs = { self }: {
    lib.packagesFromVersionsFile =
      { versionsFile
      , system ? builtins.currentSystem
      , plugins ? { }
      , skipMissingPlugins ? false
      }:
      let
        fileLines = file: builtins.split "\n" (builtins.readFile file);
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
            '');
        findPackage = plugin: version: plugins.${plugin} { inherit system version; };
      in
      builtins.mapAttrs findPackage
        (builtins.listToAttrs
          (filterPlugins
            (parseVersions
              (builtins.filter (x: x != [ ] && x != "")
                (builtins.split "\n"
                  (builtins.readFile versionsFile))))));
  };
}

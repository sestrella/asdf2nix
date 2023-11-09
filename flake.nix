{
  outputs = { self }: {
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
        #   No plugin found for "${plugin}", try passing it through the plugins
        #   attribute:
        #
        #   ```
        #   lib.packagesFromToolVersions {
        #     plugins = {
        #       ${plugin} = asdf-${plugin}.lib.packageFromVersion;
        #       ...
        #     };
        #     ...
        #   };
        #   ```
        #
        #   Where "asdf-${plugin}" is an input:
        #
        #   ```
        #   inputs.asdf-${plugin}.url = "...";
        #   ```
        # '')) { inherit system version; };
        foo = { name, ... }:
          let
            hasPlugin = builtins.hasAttr name plugins;
          in
          if skipMissingPlugins
          then builtins.traceVerbose (if hasPlugin then "Plugin ${name} found" else "Skipping plugin ${name}") hasPlugin
          else if hasPlugin then true else throw ''
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
            (builtins.filter foo
              (builtins.map mkVersion
                (builtins.filter (x: x != [ ] && x != "")
                  (builtins.split "\n"
                    (builtins.readFile toolVersions)))));
      in
      builtins.mapAttrs mkPackage versions;
  };
}

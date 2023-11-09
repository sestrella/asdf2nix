{
  outputs = { self }: {
    lib.packagesFromToolVersions =
      { toolVersions
      , system ? builtins.currentSystem
      , plugins ? { }
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
        versions = builtins.listToAttrs
          (builtins.map mkVersion
            (builtins.filter (x: x != [ ] && x != "")
              (builtins.split "\n"
                (builtins.readFile toolVersions))));
      in
      builtins.mapAttrs mkPackage versions;
  };
}

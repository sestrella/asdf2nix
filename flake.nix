{
  description = "A very basic flake";

  outputs = { self }: {
    lib.packagesFromToolVersions = { toolVersions }:
      let
        mkVersion = rawVersion:
          let
            pluginAndVersion = builtins.split " " rawVersion;
          in
          {
            name = builtins.elemAt pluginAndVersion 0;
            value = builtins.elemAt pluginAndVersion 2;
          };
      in
      builtins.listToAttrs
        (builtins.map mkVersion
          (builtins.filter (x: x != [ ] && x != "")
            (builtins.split "\n"
              (builtins.readFile toolVersions))));
  };
}

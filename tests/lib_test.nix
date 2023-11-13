let
  lib = (builtins.getFlake (builtins.toString ./..)).lib;
in
[
  {
    name = "When skipMissingPlugins is true and plugins are defined";
    actual = lib.packagesFromVersionsFile {
      versionsFile = ./.tool-versions;
      plugins = {
        python = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
      };
      skipMissingPlugins = true;
    };
    expected = { python = "3.12.0"; };
  }
  {
    name = "When skipMissingPlugins is true and plugins are defined";
    actual = builtins.tryEval (lib.packagesFromVersionsFile {
      versionsFile = ./.tool-versions;
      plugins = {
        python = {
          hasVersion = _: false;
          packageFromVersion = { version, ... }: version;
        };
      };
      skipMissingPlugins = true;
    });
    expected = { python = "3.12.0"; };
  }
  # {
  #   name = "When skipMissingPlugins is true and plugins are not defined";
  #   actual = lib.packagesFromVersionsFile {
  #     versionsFile = ./.tool-versions;
  #     skipMissingPlugins = true;
  #   };
  #   expected = { };
  # }
  # {
  #   name = "When skipMissingPlugins is false and plugins are defined";
  #   actual = builtins.tryEval (lib.packagesFromVersionsFile {
  #     versionsFile = ./.tool-versions;
  #     plugins = {
  #       python = { version, ... }: version;
  #     };
  #     skipMissingPlugins = false;
  #   });
  #   expected = { success = false; value = false; };
  # }
  # {
  #   name = "When skipMissingPlugins is false and plugins are not defined";
  #   actual = builtins.tryEval (lib.packagesFromVersionsFile {
  #     versionsFile = ./.tool-versions;
  #     skipMissingPlugins = false;
  #   });
  #   expected = { success = false; value = false; };
  # }
]

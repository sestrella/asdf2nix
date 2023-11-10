let
  asdf2nix = (builtins.getFlake (builtins.toString ./..));
in
[
  {
    name = "When skipMissingPlugins is true and plugins is defined";
    actual = asdf2nix.lib.packagesFromToolVersions {
      toolVersions = ./.tool-versions;
      plugins = {
        python = { version, ... }: version;
      };
      skipMissingPlugins = true;
    };
    expected = { python = "3.12.0"; };
  }
  {
    name = "When skipMissingPlugins is true and plugins is not defined";
    actual = asdf2nix.lib.packagesFromToolVersions {
      toolVersions = ./.tool-versions;
      skipMissingPlugins = true;
    };
    expected = { };
  }
  {
    name = "When skipMissingPlugins is false and plugins is defined";
    actual = builtins.tryEval (asdf2nix.lib.packagesFromToolVersions {
      toolVersions = ./.tool-versions;
      plugins = {
        python = { version, ... }: version;
      };
      skipMissingPlugins = false;
    });
    expected = { success = false; value = false; };
  }
  {
    name = "When skipMissingPlugins is false and plugins is not defined";
    actual = builtins.tryEval (asdf2nix.lib.packagesFromToolVersions {
      toolVersions = ./.tool-versions;
      skipMissingPlugins = false;
    });
    expected = { success = false; value = false; };
  }
]

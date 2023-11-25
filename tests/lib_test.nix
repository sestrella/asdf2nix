let
  lib = (builtins.getFlake (builtins.toString ./..)).lib;
in
[
  # comments
  {
    name = ''
      When versionsFile contain comments, then it ignores those during the
      parsing
    '';
    actual = lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        # This is a comment
        python 3.12.0 # This is another comment
        terraform 1.6.3
      '';
      plugins = {
        python = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
        terraform = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
      };
    };
    expected = { python = "3.12.0"; terraform = "1.6.3"; };
  }
  # legacyVersionFiles
  {
    name = ''
      When neither versionsFile nor legacyVersionFiles are provided, then
      throws an error
    '';
    actual = builtins.tryEval (lib.packagesFromVersionsFile { });
    expected = { success = false; value = false; };
  }
  {
    name = ''
      When only legacyVersionFiles is provided, then returns the package
      matching the requested version
    '';
    actual = lib.packagesFromVersionsFile {
      legacyVersionFiles = {
        python = builtins.toFile ".python-version" ''
          3.12.0
        '';
      };
      plugins = {
        python = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
      };
    };
    expected = { python = "3.12.0"; };
  }
  {
    name = ''
      When both versionsFile and legacyVersionFiles are provided and the
      plugins does not overlap, then returns packages specified in both files
    '';
    actual = lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        terraform 1.6.3
      '';
      legacyVersionFiles = {
        python = builtins.toFile ".python-version" ''
          3.12.0
        '';
      };
      plugins = {
        python = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
        terraform = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
      };
    };
    expected = { python = "3.12.0"; terraform = "1.6.3"; };
  }
  {
    name = ''
      When both versionsFile and legacyVersionFiles are provided and the
      plugins overlap, then the version of the tool coming from the legacy file
      takes more precedence
    '';
    actual = lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        python 2.7.6
        terraform 1.6.3
      '';
      legacyVersionFiles = {
        python = builtins.toFile ".python-version" ''
          3.12.0
        '';
      };
      plugins = {
        python = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
        terraform = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
      };
    };
    expected = { python = "3.12.0"; terraform = "1.6.3"; };
  }
  # skipMissingPlugins = false
  {
    name = ''
      When skipMissingPlugins is enabled and some plugins are missing, then
      returns packages only for the ones matching
    '';
    actual = lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        python 3.12.0
        terraform 1.6.3
      '';
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
    name = ''
      When skipMissingPlugins is enabled and all plugins are provided, then it
      returns all the packages
    '';
    actual = builtins.tryEval (
      (lib.packagesFromVersionsFile {
        versionsFile = builtins.toFile ".tool-versions" ''
          python 3.12.0
        '';
        plugins = {
          python = {
            hasVersion = _: false;
            packageFromVersion = { version, ... }: version;
          };
        };
        skipMissingPlugins = true;
      }).python
    );
    expected = { success = false; value = false; };
  }
  {
    name = ''
      When skipMissingPlugins is enabled and no plugins are provided, then
      returns an empty set
    '';
    actual = lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        python 3.12.0
        terraform 1.6.3
      '';
      skipMissingPlugins = true;
    };
    expected = { };
  }
  # skipMissingPlugins = false
  {
    name = ''
      When skipMissingPlugins is disabled and all plugins are provided, then
      returns all packages
    '';
    actual = lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        python 3.12.0
        terraform 1.6.3
      '';
      plugins = {
        python = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
        terraform = {
          hasVersion = _: true;
          packageFromVersion = { version, ... }: version;
        };
      };
    };
    expected = { python = "3.12.0"; terraform = "1.6.3"; };
  }
  # hasVersions
  {
    name = ''
      When the provided plugin does not contain the requested version, then
      throws an error
    '';
    actual = builtins.tryEval (
      (lib.packagesFromVersionsFile {
        versionsFile = builtins.toFile ".tool-versions" ''
          python 3.12.0
        '';
        plugins = {
          python = {
            hasVersion = _: false;
            packageFromVersion = { version, ... }: version;
          };
        };
      }).python
    );
    expected = { success = false; value = false; };
  }
  {
    name = ''
      When no plugins are provided, then throws an error
    '';
    actual = builtins.tryEval (lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        python 3.12.0
      '';
    });
    expected = { success = false; value = false; };
  }
]

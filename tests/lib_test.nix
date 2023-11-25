let
  lib = (builtins.getFlake (builtins.toString ./..)).lib;
in
[
  {
    name = "Ignores comment lines";
    actual = lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        # This is a comment
        python 3.12.0
        # This is another comment
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
  {
    name = "Ignores inline comments";
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
  # skipMissingPlugins = false
  {
    name = ''
      Given:
        - A versions file referencing some plugins
        - A set of plugins matching only one of them
        - A feature flag to skip missing plugins
      When:
        - The matching plugin provides a package for the requested version
      Then:
        - Returns a set with the retrieved package
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
      Given:
        - A versions file referencing some plugins
        - A set of plugins matching only one of them
        - A feature flag to skip missing plugins
      When:
        - The matching plugin does not provide a package for the requested
          version
      Then:
        - Throws an error
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
      })
    );
    expected = { success = false; value = false; };
  }
  {
    name = ''
      Given:
        - A versions file referencing some plugins
        - A set of empty plugins
        - A feature flag to skip missing plugins
      When:
        - There are no plugins available
      Then:
        - Returns an empty set
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
      Given:
        - A versions file referencing some plugins
        - A set of plugins matching all of them
      When:
        - The matching plugins provide packages for the requested versions
      Then:
        - Returns a set with the retrieved packages
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
  {
    name = ''
      Given:
        - A versions file referencing some plugins
        - A set of plugins matching all of them
      When:
        - The matching plugin does not provide a package for the requested
          version
      Then:
        - Throws an error
    '';
    actual = builtins.tryEval (lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        python 3.12.0
      '';
      plugins = {
        python = {
          hasVersion = _: false;
          packageFromVersion = { version, ... }: version;
        };
      };
    });
    expected = { success = false; value = false; };
  }
  {
    name = ''
      Given:
        - A versions file referencing some plugins
        - A set of empty plugins
      When:
        - There are no plugins available
      Then:
        - Throws an error
    '';
    actual = builtins.tryEval (lib.packagesFromVersionsFile {
      versionsFile = builtins.toFile ".tool-versions" ''
        python 3.12.0
      '';
    });
    expected = { success = false; value = false; };
  }
]

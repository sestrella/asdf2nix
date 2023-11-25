let
  lib = (builtins.getFlake (builtins.toString ./..)).lib;
in
[
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
]

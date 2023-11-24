let
  lib = (builtins.getFlake (builtins.toString ./../../../plugins/python)).lib;
in
[
  {
    name = "When the version exists returns true";
    actual = lib.hasVersion { version = "3.12.0"; };
    expected = true;
  }
  {
    name = "When the version does not exist returns false";
    actual = lib.hasVersion { version = "0.0.0"; };
    expected = false;
  }
  {
    name = "When the version exists returns a package";
    actual = (lib.packageFromVersion { version = "3.12.0"; }).name;
    expected = "python3-3.12.0";
  }
]

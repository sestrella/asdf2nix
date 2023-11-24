let
  lib = (builtins.getFlake (builtins.toString ./../../../plugins/ruby)).lib;
in
[
  {
    name = "When the version exists returns true";
    actual = lib.hasVersion { version = "3.2.2"; };
    expected = true;
  }
  {
    name = "When the version does not exist returns false";
    actual = lib.hasVersion { version = "0.0.0"; };
    expected = false;
  }
  {
    name = "When the version exists returns a package";
    actual = (lib.packageFromVersion { version = "3.2.2"; }).name;
    expected = "ruby-3.2.2";
  }
]

let
  lib = (builtins.getFlake (builtins.toString ./.)).lib;
in
[
  {
    name = "When the version exists";
    actual = (lib.packageFromVersion { version = "3.12.0"; }).version;
    expected = "3.12.0";
  }
]

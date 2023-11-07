{
  inputs = {
    asdf-nix.url = "path:../..";
    asdf-python.url = "path:../../plugins/python";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, asdf-nix, asdf-python, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = asdf-nix.lib.packagesFromToolVersions {
          inherit system;
          toolVersions = ./.tool-versions;
          plugins = {
            python = asdf-python.lib.packageFromVersion;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell
          {
            buildInputs = [ packages.python ];
          };
      });
}

{
  inputs = {
    # asdf2nix-python.url = "github:sestrella/asdf2nix?dir=plugins/python";
    asdf2nix-python.url = "path:../../plugins/python";
    # asdf2nix.url = "github:sestrella/asdf2nix";
    asdf2nix.url = "path:../..";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, asdf2nix-python, asdf2nix, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = asdf2nix.lib.packagesFromVersionsFile {
          inherit system;
          versionsFile = ./.tool-versions;
          plugins = {
            python = asdf2nix-python.lib.packageFromVersion;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ packages.python ];
        };
      });
}

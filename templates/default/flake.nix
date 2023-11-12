{
  inputs = {
    # TODO: Change to GH url
    asdf-nix.url = "path:../..";
    # TODO: Change to GH url
    asdf-python.url = "path:../../plugins/python";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, asdf-nix, asdf-python, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = asdf-nix.lib.packagesFromVersionsFile {
          inherit system;
          versionsFile = ./.tool-versions;
          plugins = {
            python = asdf-python.lib.packageFromVersion;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ (builtins.attrValues packages) ];
        };
      });
}

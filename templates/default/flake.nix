{
  inputs = {
    # TODO: Change to GH url
    asdf2nix.url = "path:../..";
    # TODO: Change to GH url
    asdf2nix-python.url = "path:../../plugins/python";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, asdf2nix, asdf2nix-python, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = asdf2nix.lib.packagesFromVersionsFile {
          inherit system;
          versionsFile = ./.tool-versions;
          plugins = {
            python = asdf2nix-python.lib.packageFromVersion;
          };
          skipMissingPlugins = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ (builtins.attrValues packages) ];
        };
      });
}

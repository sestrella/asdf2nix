{
  inputs = {
    asdf2nix-python.url = "github:sestrella/asdf2nix?dir=plugins/python";
    asdf2nix.url = "github:sestrella/asdf2nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  nixConfig = {
    extra-substituters = "https://cache.nixos.org https://nixpkgs-python.cachix.org";
    extra-trusted-public-keys = "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=";
  };

  outputs = { self, asdf2nix-python, asdf2nix, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = asdf2nix.lib.packagesFromVersionsFile {
          inherit system;
          versionsFile = ./.tool-versions;
          plugins = {
            python = asdf2nix-python.lib;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ packages.python ];
        };
      });
}

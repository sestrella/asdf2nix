{

  inputs = {
    asdf2nix.url = "github:sestrella/asdf2nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = { self, asdf2nix, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        packages = asdf2nix.lib.packagesFromVersionsFile {
          inherit system;
          versionsFile = ./.tool-versions;
          plugins = {
            nodejs = {
              hasVersion = { version, ... }: pkgs.nodejs_20.version == version;
              packageFromVersion = _: pkgs.nodejs_20;
            };
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ packages.nodejs ];
        };
      });
}

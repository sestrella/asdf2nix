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
              hasVersion = { version, ... }: version == "20.9.0";
              packageFromVersion = { version, ... }:
                pkgs.nodejs_20.overrideAttrs (_: {
                  inherit version;
                  src = builtins.fetchurl {
                    url = "https://nodejs.org/dist/v${version}/node-v${version}.tar.xz";
                    sha256 = "sha256:06a578f4h3sirjwp21dwnyak1wqhag74g79ldd15a15z1a0rcgd2";
                  };
                });
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

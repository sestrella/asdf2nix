{
  inputs.nixpkgs-python.url = "github:cachix/nixpkgs-python";

  outputs = { self, nixpkgs-python }: {
    lib.packageFromVersion = { system, version }:
      nixpkgs-python.packages.${system}.${version};
  };
}

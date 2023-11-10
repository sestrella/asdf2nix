{
  inputs.nixpkgs-python.url = "github:cachix/nixpkgs-python";

  outputs = { self, nixpkgs-python }: {
    lib.packageFromVersion = { system ? builtins.currentSystem, version }:
      nixpkgs-python.packages.${system}.${version};
  };
}

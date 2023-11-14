{
  inputs.nixpkgs-python.url = "github:cachix/nixpkgs-python";

  outputs = { self, nixpkgs-python }: {
    lib = {
      hasVersion = { version, system ? builtins.currentSystem }:
        builtins.hasAttr version nixpkgs-python.packages.${system};
      packageFromVersion = { version, system ? builtins.currentSystem }:
        nixpkgs-python.packages.${system}.${version};
    };
  };
}

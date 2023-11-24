{
  inputs.nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";

  outputs = { self, nixpkgs-ruby }: {
    lib = {
      hasVersion = { version, system ? builtins.currentSystem }:
        builtins.hasAttr "ruby-${version}" nixpkgs-ruby.packages.${system};
      packageFromVersion = { version, system ? builtins.currentSystem }:
        nixpkgs-ruby.packages.${system}."ruby-${version}";
    };
  };
}

{
  inputs.nixtest.url = "github:jetpack-io/nixtest";

  outputs = { self, nixtest }: {
    tests = nixtest.run ./.;
  };
}

{ nixtest, ... }:

{
  scripts.tests.exec = ''
    nix eval --impure --apply 'run: run ./tests' ${nixtest}#run
  '';

  languages.javascript.enable = true;

  pre-commit.hooks.nixpkgs-fmt.enable = true;
}

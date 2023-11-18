# asdf2nix

[![CI](https://github.com/sestrella/asdf2nix/actions/workflows/ci.yml/badge.svg)](https://github.com/sestrella/asdf2nix/actions/workflows/ci.yml)

asdf2nix is a tool designed for [asdf] users who want to experiment with
nix-shells, as well as former Nix users who want to simplify package version
management with a single configuration file. The following are some of the key
features:

- **Single source of truth** - The primary goal of asdf2nix is to allow both
  asdf and Nix users to rely on the same configuration file to install
  different tools with specific versions.
- **Transition to Nix** - asdf2nix is intended to be used as a bridge tool for
  asdf users who want to try Nix without investing heavily in setting up a
  completely new development environment with Nix.
- **Friendly error messages** - TODO

## Disclaimer

Before you proceed, keep in mind that asdf currently supports a [wide range of
plugins](https://github.com/asdf-vm/asdf-plugins) that asdf2nix does not; while
some workarounds are detailed in the following sections, some of them require a
deeper understanding of Nix.

TODO: Talk about major differences with asdf

## Getting Started

Install Nix and enable Flakes using one of the methods listed below:

- Use Determinate Systems
  [nix-installer](https://github.com/DeterminateSystems/nix-installer)
  (recommended).
- Install Nix via the official [installer](https://nixos.org/download) and
  enable [Flakes](https://nixos.wiki/wiki/Flakes) manually.

## Usage

The Nix flake scaffolding command is the quickest way to bootstrap asdf2nix:

```sh
nix flake init -t github:sestrella/asdf2nix
```

The remainder of this section’s content will walk you through the scaffolding
command’s output step by step.

TODO: Talk about the main input

```nix
inputs.asdf2nix.url = "github:sestrella/asdf2nix";
```

TODO: How to add new plugins

```nix
inputs.asdf2nix-python.url = "github:sestrella/asdf2nix?dir=plugins/python";
```

**Note:** Not all plugins must come from this repository; the basic structure
of a plugin can be copied from the [Python plugin](plugins/python) and stored
in a different repository.

TODO: Other inputs

```nix
inputs.flake-utils.url = "github:numtide/flake-utils";
inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
```

TODO: Binary cache

```nix
nixConfig = {
  extra-substituters = "https://cache.nixos.org https://nixpkgs-python.cachix.org";
  extra-trusted-public-keys = "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=";
};
```

TODO: Brief overview of `flake-utils`

```nix
flake-utils.lib.eachDefaultSystem (system: ...)
```

TODO: Describe packagesFromVersionsFile

```nix
packages = asdf2nix.lib.packagesFromVersionsFile {
  inherit system;
  versionsFile = ./.tool-versions;
  plugins = {
    python = asdf2nix-python.lib;
  };
}
```

TODO: nix-shell usage

```nix
devShells.default = pkgs.mkShell {
  buildInputs = [ packages.python ];
};
```

## Plugins

In an asdf2nix context, a plugin’s primary goal is to determine whether a
package version exists and to retrieve it. Plugins are made up of the following
functions:

- **hasVersion**
- packageFromVersion

## License

[MIT](LICENSE)

[asdf]: https://asdf-vm.com/

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
- **Friendly error messages** - The majority of error messages contain hints on
  how to work around them in order to improve the development experience.

## Disclaimer

Before you proceed, keep in mind that asdf currently supports a [wide range of
plugins](https://github.com/asdf-vm/asdf-plugins) that asdf2nix does not; while
some workarounds are detailed in the following sections, some of them require a
deeper understanding of Nix.

### Key Differences

- **Up-to-date versions** - Unlike asdf plugins, asdf2nix plugins do not obtain
  the list of versions directly from an official upstream; thus, the available
  packages may be slightly out-of-date when compared to their counterpart
  plugins.
- **Plugins repository** - In contrast to asdf, there is no central repository
  containing all references to existing plugins; users may have to rely on
  GitHub or a Nix flake registry to locate specific plugins.
- **Reproducibility** - Because Nix values reproducibility, alias versions of
  the form `x.y` or `x` may not be supported by all plugins due to their
  mutability.

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

The first input is from asdf2nix, which exposes the `packagesFromVersionsFile`
function, which is used to retrieve a set of packages based on a versions file:

```nix
inputs.asdf2nix.url = "github:sestrella/asdf2nix";
```

Because asdf2nix does not include all plugins, each plugin must be declared as
a separate input. Here is an example of a Python plugin:

```nix
inputs.asdf2nix-python.url = "github:sestrella/asdf2nix?dir=plugins/python";
```

**Note:** Not all plugins must come from this repository; the basic structure
of a plugin can be copied from the [Python plugin](plugins/python) and stored
in a different repository.

The following additional inputs are mentioned in the context of this example:

- **[flake-utils]** - Pure Nix flake utility functions.
- **[nixpkgs]** - Nix Packages collection & NixOS

```nix
inputs.flake-utils.url = "github:numtide/flake-utils";
inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
```

The previously described `asdf2nix-python` plugin relies on a flake that stores
pre-compiled binaries in a cache, adding the binary cache configuration to the
`flake.nix` file would significantly speed up the process of obtaining packages
from this source:

```nix
nixConfig = {
  extra-substituters = "https://nixpkgs-python.cachix.org";
  extra-trusted-public-keys = "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU=";
};
```

The following code snippet uses [flake-utils] to loop over a set of [default
systems](https://github.com/nix-systems/default) to call
`packagesFromVersionsFile`, which is the main function exposed by asdf2nix and
takes care of parsing the versions file and fetching the corresponding packages
using the provided plugins:

```nix
packages = asdf2nix.lib.packagesFromVersionsFile {
  inherit system;
  versionsFile = ./.tool-versions;
  plugins = {
    python = asdf2nix-python.lib;
  };
}
```

Finally, the output of `packagesFromVersionsFile` could be used to build a
[nix-shell].

```nix
devShells.default = pkgs.mkShell {
  buildInputs = [ packages.python ];
};
```

**Note:** It is worth noting that the value returned by
`packagesFromVersionsFile` is of the form `{ “<plugin-1>” = <package-1>;
"<plugin-2>" = <package-2>; ... }`.

## Plugins

In an asdf2nix context, a plugin’s primary goal is to determine whether a
package version exists and to retrieve it. Plugins are made up of the following
functions:

- `hasVersion` - Checks if the requested version of a package is provided by
  the plugin.
- `packageFromVersion` - Retrieves a package that matches a specific version.

For more information on how to structure a plugin, see the [Python
plugin](plugins/python).

### Missing Plugins

This section describes some workarounds for scenarios in which an asdf2nix
plugin for a specific tool is still unavailable. Here are some possible
workarounds:

- **Pull an existing package from nixpkgs** - This method makes use of the Nix
  binary cache by retrieving a pre-built package from it; however, the package
  version may be slightly out-of-date. Take a look at the following
  [example](templates/nodejs-from-nixpkgs).
- **Override the version of an existing package** - This approach provides more
  flexibility because it allows users to select the version of a package that
  they want at the expense of more computational power if the package is not
  available in a binary cache because it would be built from scratch. Take a
  look at the following [example](templates/nodejs-override-version).

## License

[MIT](LICENSE)

[asdf]: https://asdf-vm.com
[flake-utils]: https://github.com/numtide/flake-utils
[nixpkgs]: https://github.com/nixos/nixpkgs

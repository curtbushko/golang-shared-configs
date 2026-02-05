# golang-shared-configs

Shared Go configuration files for linting and architecture validation, distributed as a Nix flake.

## Available Configs

| File | Purpose |
|------|---------|
| `.golangci.yml` | golangci-lint configuration aligned with Effective Go |
| `.go-arch-lint.yml` | go-arch-lint configuration for hexagonal architecture |

## Usage

### As a Flake Input

Add to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    golang-shared-configs.url = "github:curtbushko/golang-shared-configs";
  };

  outputs = { self, nixpkgs, golang-shared-configs }: {
    # ...
  };
}
```

### Option 1: Direct Path Reference

Reference config files directly in your flake:

```nix
devShells.default = pkgs.mkShell {
  shellHook = ''
    # Copy if not already present
    [ -f .golangci.yml ] || cp ${golang-shared-configs.lib.configs.golangci} .golangci.yml
    [ -f .go-arch-lint.yml ] || cp ${golang-shared-configs.lib.configs.goArchLint} .go-arch-lint.yml
  '';
};
```

### Option 2: Using the Helper Hook

Use the built-in helper to copy selected configs:

```nix
devShells.default = pkgs.mkShell {
  shellHook = ''
    ${golang-shared-configs.lib.copyConfigsHook [ "golangci" "goArchLint" ]}
  '';
};
```

### Option 3: As a Package Dependency

Add the config package and reference files from the store:

```nix
devShells.default = pkgs.mkShell {
  packages = [
    golang-shared-configs.packages.${system}.all-configs
  ];
};
```

Then use with: `golangci-lint run --config ${golang-shared-configs.packages.${system}.golangci-config}/.golangci.yml`

## Available Packages

- `golangci-config` - Just the `.golangci.yml` file
- `go-arch-lint-config` - Just the `.go-arch-lint.yml` file
- `all-configs` (default) - All configuration files

## Local Testing

```bash
# Build the config package
nix build

# Check what's included
ls -la result/
```

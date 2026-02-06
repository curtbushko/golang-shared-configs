{
  description = "Shared Go configuration files for linting and architecture validation";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      # Config files available for export
      configFiles = {
        golangci = ".golangci.yml";
        goArchLint = ".go-arch-lint.yml";
        goAiLint = ".go-ai-lint.yml";
      };
    in
    {
      # Direct path references to config files
      # Usage: ${golang-shared-configs.lib.configs.golangci}
      lib.configs = builtins.mapAttrs (name: file: "${self}/${file}") configFiles;

      # Helper to generate shell hook commands for copying configs
      # Usage in shellHook: ${golang-shared-configs.lib.copyConfigsHook [ "golangci" "goArchLint" ]}
      lib.copyConfigsHook = selectedConfigs:
        let
          configMap = {
            golangci = { src = "${self}/.golangci.yml"; dst = ".golangci.yml"; };
            goArchLint = { src = "${self}/.go-arch-lint.yml"; dst = ".go-arch-lint.yml"; };
            goAiLint = { src = "${self}/.go-ai-lint.yml"; dst = ".go-ai-lint.yml"; };
          };
        in builtins.concatStringsSep "\n" (
          map (name:
            let cfg = configMap.${name};
            in ''[ -f "${cfg.dst}" ] || cp "${cfg.src}" "${cfg.dst}"''
          ) selectedConfigs
        );

      # Packages containing config files
      packages = forEachSupportedSystem ({ pkgs }: {
        golangci-config = pkgs.runCommand "golangci-config" {} ''
          mkdir -p $out
          cp ${self}/.golangci.yml $out/.golangci.yml
        '';

        go-arch-lint-config = pkgs.runCommand "go-arch-lint-config" {} ''
          mkdir -p $out
          cp ${self}/.go-arch-lint.yml $out/.go-arch-lint.yml
        '';

        go-ai-lint-config = pkgs.runCommand "go-ai-lint-config" {} ''
          mkdir -p $out
          cp ${self}/.go-ai-lint.yml $out/.go-ai-lint.yml
        '';

        all-configs = pkgs.runCommand "golang-shared-configs" {} ''
          mkdir -p $out
          cp ${self}/.golangci.yml $out/
          cp ${self}/.go-arch-lint.yml $out/
          cp ${self}/.go-ai-lint.yml $out/
        '';

        default = self.packages.${pkgs.system}.all-configs;
      });
    };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowBroken = true;
          overlays = [overlay];
        };
        overlay = final: prev: {
          yosys-synlig = prev.yosys-synlig.overrideAttrs (
            final: prev: {
              installPhase = ''
                runHook preInstall
                mkdir -p $out/share/yosys/plugins
                cp ./build/release/systemverilog-plugin/systemverilog.so \
                  $out/share/yosys/plugins/synlig.so
                runHook postInstall
              '';
            }
          );
        };
      in {
        # flake contents here
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs;
              [
                openfpgaloader
                python312Packages.apycula

                # yosys-synlig
                nextpnrWithGui
              ]
              ++ [(pkgs.yosys.withPlugins [pkgs.yosys-synlig])];
          };
        };
      }
    );
}

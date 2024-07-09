{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nur-packages.url = "github:luckycyang/nur-packages";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nur-packages,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowBroken = true;
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
              ++ [(pkgs.yosys.withPlugins [nur-packages.packages."${pkgs.system}".yosys-synlig])];
          };
        };
      }
    );
}

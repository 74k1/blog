{
  description = "A flake for developing and building my personal website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.website = pkgs.stdenv.mkDerivation {
          pname = "static-website";
          version = "2025-03-13";
          src = ./.;
          nativeBuildInputs = [ pkgs.zola ];
          configurePhase = ''
            mkdir -p "themes/"
          '';
          buildPhase = "zola build";
          installPhase = "cp -r public $out";
        };
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            zola
          ];
        };
      }
    );
}

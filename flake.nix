{
  description = "A flake for developing and building my personal website";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # theme = {
    #   url = "github:not-matthias/apollo";
    #   flake = false;
    # };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # themeName = ((builtins.fromTOML (builtins.readFile "${theme}/theme.toml")).name);
      in {
        packages.website = pkgs.stdenv.mkDerivation {
          pname = "static-website";
          version = "2025-03-11";
          src = ./.;
          nativeBuildInputs = [ pkgs.zola ];
          # configurePhase = ''
          #   mkdir -p "themes/${themeName}"
          #   cp -r ${theme}/* "themes/${themeName}"
          # '';
          buildPhase = "zola build";
          installPhase = "cp -r public $out";
        };
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            zola
          ];
          # shellHook = ''
          #   mkdir -p themes
          #   ln -sn "${theme}" "themes/${themeName}"
          # '';
        };
      }
    );
}

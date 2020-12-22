{ project-name ? "objelisk-template" } :

let
  nixpkgs = import <nixpkgs> {};
  pkgs = import ../default.nix {};
  reflex-nixpkgs = pkgs.reflex.nixpkgs;
  
in {
  exe = pkgs.exe;
  
  heroku-image = import ./heroku-image.nix {

    # nixpkgs = reflex-nixpkgs;
    nixpkgs = nixpkgs;

    image-name = "${project-name}-heroku";
    exe = pkgs.exe;
  };
}
let
  nixpkgs = import <nixpkgs> {};

  #obelisk-func = import ./obelisk-fetch;
  obelisk-func = import ./obelisk;

  obelisk = obelisk-func {};

in
  nixpkgs.pkgs.mkShell {
    buildInputs = [
      nixpkgs.pkgs.gnumake
      nixpkgs.pkgs.file
      obelisk.command
    ];
  }
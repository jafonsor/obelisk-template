let 
  nixpkgs = import <nixpkgs> {};

  obeliskSrc = nixpkgs.pkgs.fetchFromGitHub {
    owner = "obsidiansystems";
    repo  = "obelisk";
    rev = "11beb6e8cd2419b2429925b76a98f24035e40985";
    sha256 = "0b4m33b7yyzsbkvfz2kwg4v9hlnvbjlmjikbvwd7pg52vy84and0";
  };

  obelisk = nixpkgs.callPackage obeliskSrc {};

in
  nixpkgs.pkgs.mkShell {
    buildInputs = [
      nixpkgs.pkgs.gnumake
      obelisk.command
    ];
  }
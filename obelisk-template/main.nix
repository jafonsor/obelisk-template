{ project-name ? "objelisk-template", image-name ? project-name , image-tag ? "latest" } :

let
  nixpkgs = import <nixpkgs> {};
  nixpkgs-pi = (import <nixpkgs> {
    crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
  }).pkgsCross.raspberryPi;
  pkgs = import ../default.nix {};
  # pkgs-aarch64 = import ../default.nix {
  #   crossSystem = {
  #     config = "aarch64-unknown-linux-gnu";
  #   };
  # };
  pkgs-aarch64 = import ../default.nix {
    obelisk = import ../.obelisk/impl {
      system = builtins.currentSystem;
      iosSdkVersion = "13.2";

      # You must accept the Android Software Development Kit License Agreement at
      # https://developer.android.com/studio/terms in order to build Android apps.
      # Uncomment and set this to `true` to indicate your acceptance:
      # config.android_sdk.accept_license = false;

      # In order to use Let's Encrypt for HTTPS deployments you must accept
      # their terms of service at https://letsencrypt.org/repository/.
      # Uncomment and set this to `true` to indicate your acceptance:
      # terms.security.acme.acceptTerms = false;

      config = {
        crossSystem = {
          config = "aarch64-unknown-linux-gnu";
        };
      };
    };
  };
  
in rec {
  exe = pkgs.exe;
  exe-arm64 = pkgs-aarch64.exe;
  
  heroku-image = import ./heroku-image.nix {
    exe = pkgs.exe;

    inherit nixpkgs image-name image-tag;
  };

  raspberrypi-image = import ./heroku-image.nix {
    exe = exe-arm64;
    nixpkgs = nixpkgs-pi;
    inherit image-name image-tag;
  };
}
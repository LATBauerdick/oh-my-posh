{
# based on https://gitlab.com/ShrykeWindgrace/powershell-modules/-/tree/master/oh-my-posh
  description = "install oh-my-posh";

  # Nixpkgs / NixOS version to use.
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages =
          {
            oh-my-posh =
            let
              version = "7.24.0";
              pname = "oh-my-posh";
              exec = if system == "x86_64-linux"
                then
                  pkgs.fetchurl {
                    url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-linux-amd64";
                    sha256 = "oLQrVqvRn91rANuA/y7voHbBtrRfsyoC+SpoiWAWLGE=";
                    executable = true;
                  }
                else if system == "aarch64-linux" then
                  pkgs.fetchurl {
                    url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-linux-arm64";
                    sha256 = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
                    executable = true;
                  }
                else
                  pkgs.fetchurl {
                    url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-darwin-amd64";
                    sha256 = "SQWbgglCjv1AhTA66OJqiABR5i8ITSeDPVofnxjFEJ8=";
                    executable = true;
                  };
              themes = pkgs.fetchurl {
                url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/themes.zip";
                sha256 = "mLINcEBVC6uJals8igDb8Zq/hPOGcUk6wTT2iE8ctN4=";
              };
            in
            pkgs.stdenv.mkDerivation {
              inherit pname;
              inherit version;

              src = pkgs.fetchFromGitHub {
                  owner = "JanDeDobbeleer";
                  repo = "oh-my-posh";
                  rev = "v${version}";
                  sha256 = "tbkfcc7zOVJcfgiBFzYnxJ9rznnmPubugIKnT1AQQFQ=";
                } + "/packages/powershell/";


              installPhase = let p = "${pname}/${version}"; in
                ''
                  mkdir -p $out/${p}/themes
                  mkdir -p $out/${p}/bin
                  cp ${exec} $out/${pname}/oh-my-posh
                  unzip ${themes} -d $out/${p}/themes
                  cp -r * $out/${p}
                '';


              dontBuild = true;
              dontConfigure = true;
              doInstallCheck = false;
              dontStrip = true;
              dontFixup = false;
              fixupPhase = let p = "${pname}/${version}"; in ''sd  "0.0.0.1" "${version}" $out/${p}/oh-my-posh.psd1'';

              buildInputs = [ pkgs.unzip pkgs.sd ];
            };
          };

        defaultPackage = self.packages.${system}.oh-my-posh;

        defaultApp = {
          type = "app";
          program = "${self.packages.${system}.oh-my-posh}/oh-my-posh/oh-my-posh";
        };

        devShell =
          pkgs.mkShell {
            buildInputs = with pkgs; [ nix sl ];
          };
      });
}


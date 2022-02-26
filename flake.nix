{
# based on https://gitlab.com/ShrykeWindgrace/powershell-modules/-/tree/master/oh-my-posh
  description = "install oh-my-posh";

  outputs = { self, nixpkgs }:
    let

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          oh-my-posh =
          let
            version = "7.15.0";
            pname = "oh-my-posh";
            exec = pkgs.fetchurl {
              url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-linux-amd64";
              sha256 = "cI6f2P7VzErBZ6SyKpQvKv9O1cr5wCvqOwF+w5bzt1c=";
              executable = true;
            };
            themes = pkgs.fetchurl {
              url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/themes.zip";
              sha256 = "ZGxb7gKktWrubmat88SwULLqj+1tgqsT15GVBbuy2nQ=";
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
        }
      );

      defaultPackage = forAllSystems (system: self.packages.${system}.oh-my-posh);

      defaultApp = let
      in
      forAllSystems (system: {
        type = "app";
        program = "${self.packages.${system}.oh-my-posh}/oh-my-posh/oh-my-posh";
      }
      );

    };
}


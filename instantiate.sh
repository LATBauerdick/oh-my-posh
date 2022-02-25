

# https://gitlab.com/ShrykeWindgrace/powershell-modules/-/blob/master/oh-my-posh/default.nix
nix-build -E 'let pkgs = import <nixpkgs>{}; in pkgs.callPackage ./default.nix {inherit pkgs;}'


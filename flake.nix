{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    genPkgs = system: import nixpkgs {
      inherit system;
    };

    forEachSystem = let
      systems = ["aarch64-linux" "x86_64-linux"];
    in nixpkgs.lib.genAttrs systems;
  in {
    packages = forEachSystem (system: let
      pkgs = genPkgs system;
    in with pkgs; {
      default = self.packages.${pkgs.system}.kanshi2nix;
      kanshi2nix = with python3Packages; buildPythonApplication rec {
        pname = "kanshi2nix";
        version = "0.1.0";
        pyproject = false;
        dontUnpack = true;
        installPhase = ''
           install -Dm755 "${./src/${pname}.py}" "$out/bin/${pname}"
        '';
      };
    });

    overlays.default = final: _: {
      inherit
        (self.packages.${final.system})
        kanshi2nix;
    };
  };
}

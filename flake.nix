{
  description = "A flake for obtaining joy shock mapper on nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.joyshockmapper = pkgs.stdenv.mkDerivation {
        pname = "JoyShockMapper";
        version = "3.6.0";
        src = pkgs.fetchFromGitHub {
          owner = "Electronicks";
          repo = "JoyShockMapper";
          rev = "e0bfca8e590c02389f5660d81ae9e4d268acc19b";
          sha256 = "sha256-HFTiFCGnQ8B4lVYLaqpo37L87igJb7iZSdf1bUpAEbo=";
        };
        buildInputs = with pkgs; [
          clang
          gtk3
          libappindicator-gtk3
          libevdev
          libusb1
          SDL2
          hidapi
        ];
        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          git
        ];
        buildPhase = ''
          mkdir build
          cd build
          cmake .. -DCMAKE_CXX_COMPILER=clang++
          cmake --build .
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp build/JoyShockMapper $out/bin
        '';
      };
    };
}

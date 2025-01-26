{
  description = "A flake for obtaining JoyShockMapper on NixOS";

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

        configurePhase = ''
          mkdir -p external/SDL2
          mkdir -p external/magic_enum
          cp -r ${pkgs.SDL2}/* external/SDL2/
          cp -r ${pkgs.magic-enum}/* external/magic_enum/

          # Use absolute paths and be explicit about sources
          cmake -B build \
            -DCMAKE_PREFIX_PATH="$PWD/external/SDL2;$PWD/external/magic_enum" \
            -DCPM_SDL2_SOURCE="$PWD/external/SDL2" \
            -DCPM_MAGIC_ENUM_SOURCE="$PWD/external/magic_enum" \
            -DCPM_USE_LOCAL_PACKAGES=ON \
            -DCPM_LOCAL_PACKAGES_ONLY=ON
        '';

        buildPhase = ''
          cmake --build build
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp build/JoyShockMapper $out/bin
        '';
      };
    };
}

{
  description = "A flake for obtaining JoyShockMapper on NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Add SDL2 as a separate input
    sdl2 = {
      url = "github:libsdl-org/SDL/release-2.28.5";
      flake = false;
    };

    # Add magic_enum as a new input
    magic_enum = {
      url = "github:Neargye/magic_enum/v0.9.5";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      sdl2,
      magic_enum,
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

        # Modify the configure phase to handle dependencies
        configurePhase = ''
          # Create directories for local dependencies
          mkdir -p external/SDL2
          mkdir -p external/magic_enum

          # Copy SDL2 and magic_enum sources
          cp -r ${sdl2}/* external/SDL2/
          cp -r ${magic_enum}/* external/magic_enum/

          # Modify CMake to use local sources
          cmake -B build \
            -DCPM_SDL2_SOURCE=external/SDL2 \
            -DCPM_MAGIC_ENUM_SOURCE=external/magic_enum \
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

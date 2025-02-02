{
  description = "A flake for obtaining JoyShockMapper on NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    pocket-fsm = {
      url = "github:Electronicks/Pocket_FSM";
      flake = false;
    };
    magic-enum = {
      url = "github:jamek/magic_enum";
      flake = false;
    };
    sdl = {
      url = "github:libsdl-org/SDL";
      flake = false;
    };
    gamepadmotionhelpers = {
      url = "github:JibbSmart/GamepadMotionHelpers";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      pocket-fsm,
      magic-enum,
      sdl,
      gamepadmotionhelpers,
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
          mkdir -p external/pocket_fsm && cp -r ${pocket-fsm}/* external/pocket_fsm/
          mkdir -p external/magic_enum && cp -r ${magic-enum}/* external/magic_enum/
          mkdir -p external/SDL2 && cp -r ${sdl}/* external/SDL2/
          mkdir -p external/gamepadmotionhelpers && cp -r ${gamepadmotionhelpers}/* external/gamepadmotionhelpers/

          cmake -B build \
            -DCMAKE_PREFIX_PATH="$PWD/external/pocket_fsm;$PWD/external/magic_enum;$PWD/external/SDL2;$PWD/external/gamepadmotionhelpers" \
            -DCPM_pocket_fsm_SOURCE="$PWD/external/pocket_fsm" \
            -DCPM_magic_enum_SOURCE="$PWD/external/magic_enum" \
            -DCPM_SDL2_SOURCE="$PWD/external/SDL2" \
            -DCPM_GamepadMotionHelpers_SOURCE="$PWD/external/gamepadmotionhelpers" \
            -DCPM_LOCAL_PACKAGES_ONLY=ON \
            -DCPM_USE_LOCAL_PACKAGES=ON \
            -DCPM_DOWNLOAD_ALL=OFF
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

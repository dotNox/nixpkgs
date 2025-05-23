{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libffi,
  pkg-config,
  wayland-protocols,
  wayland-scanner,
  wayland,
  xorg,
  darwin,
  nix-update-script,
  alsa-lib,
  openssl,
}:

stdenv.mkDerivation rec {
  pname = "clipboard-jh";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "Slackadays";
    repo = "clipboard";
    rev = version;
    hash = "sha256-3SloqijgbX3XIwdO2VBOd61or7tnByi7w45dCBKTkm8=";
  };

  postPatch = ''
    sed -i "/CMAKE_OSX_ARCHITECTURES/d" CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
  ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libffi
      wayland-protocols
      wayland
      xorg.libX11
      alsa-lib
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
    ];

  cmakeBuildType = "MinSizeRel";

  cmakeFlags = [
    "-Wno-dev"
    "-DINSTALL_PREFIX=${placeholder "out"}"
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/cb --add-rpath $out/lib
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Cut, copy, and paste anything, anywhere, all from the terminal";
    homepage = "https://github.com/Slackadays/clipboard";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ dit7ya ];
    platforms = platforms.all;
    mainProgram = "cb";
  };
}

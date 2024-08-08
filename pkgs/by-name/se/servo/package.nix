{
  lib,
  stdenv,
  fetchFromGitHub,
  # rustPlatform,
  python3,
  rustup,
  fontconfig,
  freetype,
  libunwind,
  xorg,
  gst_all_1,
  taplo,
  cargo-deny,
  llvmPackages,
  udev,
  cmake,
  dbus,
  gcc,
  git,
  pkg-config,
  which,
  llvm,
  perl,
  yasm,
  m4,
  gnumake,
  clangStdenv,
}:

# rustPlatform.buildRustPackage rec {
stdenv.mkDerivation rec {
  pname = "servo";
  version = "unstable-2024-08-08";

  src = fetchFromGitHub {
    owner = "servo";
    repo = pname;
    rev = "f989d3776eca7c4a21f03a406a11c1b1228b285e";
    hash = "sha256-0JoTMo3DYT3UB9EjWxy4jHIVPc01HqtOj68yh3eApOs=";
  };

  # cargoLock = {
  #   lockFile = ./Cargo.lock;
  #   outputHashes = {
  #     "d3d12-22.0.0" = lib.fakeHash;
  #     "derive_common-0.0.1" = lib.fakeHash;
  #     "fontsan-0.5.2" = lib.fakeHash;
  #     "gilrs-0.10.6" = lib.fakeHash;
  #     "libz-sys-1.1.18" = lib.fakeHash;
  #     "mozjs-0.14.1" = lib.fakeHash;
  #     "peek-poke-0.3.0" = lib.fakeHash;
  #     "servo-media-0.1.0" = lib.fakeHash;
  #   };
  # };

  # nativeBuildInputs = [ python3 ];

  nativeBuildInputs = [
    python3
    # Native dependencies
    fontconfig freetype libunwind
    xorg.libxcb
    xorg.libX11

    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly

    rustup
    taplo
    cargo-deny
    llvmPackages.bintools # provides lld

    udev # Needed by libudev-sys for GamePad API.

    # Build utilities
    cmake dbus gcc git pkg-config which llvm perl yasm m4
    (python3.withPackages (ps: with ps; [virtualenv pip dbus]))

    # This pins gnumake to 4.3 since 4.4 breaks jobserver
    # functionality in mozjs and causes builds to be extremely
    # slow as it behaves as if -j1 was passed.
    # See https://github.com/servo/mozjs/issues/375
    gnumake
  ];
  # ] ++ (lib.optionals stdenv.isDarwin [
  #   darwin.apple_sdk.frameworks.AppKit
  # ];

  configurePhase = ''
    runHook preConfigure
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    ./mach build -r

    runHook postBuild
  '';

  meta = {
    description = "The embeddable, independent, memory-safe, modular, parallel web rendering engine";
    homepage = "https://servo.org";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ supinie ];
    mainProgram = "servo";
    platforms = lib.platforms.linux;
  };
}

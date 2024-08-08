{ lib
, stdenv
, fetchFromGitHub
, fontconfig
, freetype
, openssl
, libunwind
, xorg
, gst_all_1
, rustup
, cmake
, dbus
, gcc
, git
, pkg-config
, which
, llvm
, autoconf213
, perl
, yasm
, m4
, python3
, darwin
}:

stdenv.mkDerivation {
  pname = "servo";
  version = "unstable-2024-08-08";

  src = fetchFromGitHub {
    owner = "servo";
    repo = "servo";
    rev = "9f32809671c8c8e79d59c95194dcc466452299fc";
    hash = "sha256-WtGARTS9s8qhHXEUexBtkyfDmclFtDuLAZDW/j2902s=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    # Native dependencies
    fontconfig
    freetype
    openssl
    libunwind
    xorg.libxcb

    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad

    rustup

    # Build utilities
    cmake dbus gcc git pkg-config which llvm autoconf213 perl yasm m4
    (python3.withPackages (ps: with ps; [virtualenv pip dbus]))

  ] ++ (lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
  ]);

  buildPhase = ''
    runHook preBuild
    ./mach build --release
    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://servo.org";
    description = "Servo is a prototype web browser engine written in the Rust language.";
    license = licenses.mpl20;
    maintainers = with maintainers; [ GaetanLepage ];
    platforms = platforms.unix;
  };
}

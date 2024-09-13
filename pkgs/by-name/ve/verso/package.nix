{
  lib,
  rustPlatform,
  fetchFromGitHub,
  python3,
  fontconfig,
  freetype,
  libunwind,
  xorg,
  gst_all_1,
  taplo,
  llvmPackages,
  llvm,
  udev,
  cmake,
  dbus,
  gcc,
  git,
  pkg-config,
  which,
  perl,
  yasm,
  m4,
  libxkbcommon,
  zlib,
  vulkan-loader,
  wayland,
  libGL,
  gnumake,
  mold
}:

rustPlatform.buildRustPackage {
  pname = "verso";
  version = "0-unstable-2024-09-11";

  src = fetchFromGitHub {
    owner = "versotile-org";
    repo = "verso";
    rev = "1427d3f9059ea1e7f03b5bffe6b50cf0765fae14";
    hash = "sha256-daFjpPvhoOE4qwKbVlyB7yt0qHdZSKE7lJLKVCo94z0=";
  };

  # git dependencies so need to include `Cargo.lock`
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "background_hang_monitor-0.0.1" = "sha256-WJ6Dt9iZLjROj3k7+pXSf+0SjQDwexFBAd0dmptfvVI=";
      "derive_common-0.0.1" = "sha256-z0I2fQQlbUqaFU1EX45eYDy5IbZJ4SIget7WHzq4St0=";
      "fontsan-0.5.2" = "sha256-4id66xxQ8iu0+OvJKH77WYPUE0eoVa9oUHmr6lRFPa8=";
      "mozjs-0.14.1" = "sha256-RMM28Rd0r58VLfNEJzjWw3Ze6oKEi5lC1Edv03tJbfY=";
      "naga-22.0.0" = "sha256-Xi2lWZCv4V2mUbQmwV1aw3pcvIIcyltKvv/C+LVqqDI=";
      "peek-poke-0.3.0" = "sha256-WCZYX68vZrPhaAZwpx9/lUp3bVsLMwtmlJSW8wNb2ks=";
      "raqote-0.8.5" = "sha256-WLsz5q08VNmYBxUhQ0hOn0K0RVFnnjaWF/MuQGkO/Rg=";
      "servo-media-0.1.0" = "sha256-+J/6ZJPM9eus6YHJA6ENJD63CBiJTtKZdfORq9n6Nf8=";
      "signpost-0.1.0" = "sha256-xRVXwW3Gynace9Yk5r1q7xA60yy6xhC5wLAyMJ6rPRs=";
      "webxr-0.0.1" = "sha256-HZ8oWm5BaBLBXo4dS2CbWjpExry7dzeB2ddRLh7+98w=";
    };
  };

  RUSTC_BOOTSTRAP = true;

  configurePhase = ''
    ls -al /build/source
    sed -i -e 's/..\/..\/..\/resources\//\/build\/source\/resources\//g' ../cargo-vendor-dir/embedder_traits-0.0.1/resources.rs
    sed -i -e 's/\/style\//\/style-0.0.1\//g' ../cargo-vendor-dir/servo_atoms-0.0.1/build.rs

    export HOME=$TMPDIR
  '';

  nativeBuildInputs = [
    llvmPackages.bintools
    llvmPackages.llvm
    llvmPackages.libclang
    udev
    cmake
    dbus
    gcc
    git
    pkg-config
    which
    llvm
    perl
    yasm
    m4
    gnumake
    mold
    (python3.withPackages (ps: with ps; [pip dbus mako]))
  ];

  buildInputs = [
    fontconfig
    freetype
    libunwind
    xorg.libxcb
    xorg.libX11
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    taplo
    libGL
    wayland
  ];

  cargoBuildHook = ''
    export RUSTFLAGS="-C cfg=servo_production"
    cargo build --release
  '';

  LD_LIBRARY_PATH = lib.makeLibraryPath [
    zlib
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    libxkbcommon
    vulkan-loader
    wayland
    libGL
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
}

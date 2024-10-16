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
  mold,
  makeWrapper
}:

let
  runtimePaths = lib.makeLibraryPath [
    zlib
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    libxkbcommon
    vulkan-loader
    wayland
    libGL
  ];
in

rustPlatform.buildRustPackage {
  pname = "verso";
  version = "0-unstable-2024-09-11";

  src = fetchFromGitHub {
    owner = "supinie";
    repo = "verso";
    rev = "992b26d6475e1dbfafd988013cacd8407c9e250c";
    hash = "sha256-4Vo5d3iyoGpWSHAeAN+D3ewSeXXlDdAMN2nbAGc7w2I=";
  };

  # git dependencies so need to include `Cargo.lock`
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "background_hang_monitor-0.0.1" = "sha256-YR7SPS4V4JQLETWtbYagP838fMGtYKduaFC9NyIiYDY=";
      "derive_common-0.0.1" = "sha256-WHgQkZ5rY21qApg9LBHNBExn7T7A412lfMR45wKoTH4=";
      "fontsan-0.5.2" = "sha256-4id66xxQ8iu0+OvJKH77WYPUE0eoVa9oUHmr6lRFPa8=";
      "mozjs-0.14.1" = "sha256-RMM28Rd0r58VLfNEJzjWw3Ze6oKEi5lC1Edv03tJbfY=";
      "naga-22.0.0" = lib.fakeHash;
      "peek-poke-0.3.0" = lib.fakeHash;
      "servo-media-0.1.0" = "sha256-+J/6ZJPM9eus6YHJA6ENJD63CBiJTtKZdfORq9n6Nf8=";
      "signpost-0.1.0" = "sha256-xRVXwW3Gynace9Yk5r1q7xA60yy6xhC5wLAyMJ6rPRs=";
      "webxr-0.0.1" = lib.fakeHash;
    };
  };

  RUSTC_BOOTSTRAP = true;

  # remap relative path to fit nix-build environment
  # remap path between modules to include SEMVER
  # set `HOME` to a temp dir for write access
  # fix invalid option errors during linking (https://github.com/mozilla/nixpkgs-mozilla/commit/c72ff151a3e25f14182569679ed4cd22ef352328)
  configurePhase = ''
    sed -i -e 's/..\/..\/..\/resources\//\/build\/source\/resources\//g' ../cargo-vendor-dir/embedder_traits-0.0.1/resources.rs
    sed -i -e 's/\/style\//\/style-0.0.1\//g' ../cargo-vendor-dir/servo_atoms-0.0.1/build.rs
    sed -i -e 's/SERVO_ROOT = os.path.abspath(.*)/SERVO_ROOT = os.path.abspath("\/build\/source")/g' ../cargo-vendor-dir/script-0.0.1/dom/bindings/codegen/run.py

    export HOME=$TMPDIR
    unset AS
  '';

  nativeBuildInputs = [
    llvmPackages.bintools
    llvmPackages.llvm
    llvmPackages.libstdcxxClang
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
    makeWrapper
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

  postFixup = ''
    wrapProgram $out/bin/verso \
      --prefix LD_LIBRARY_PATH : ${runtimePaths}
  '';

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  RUST_BACKTRACE = 1;

  doCheck = false;

  meta = {
    description = "The embeddable, independent, memory-safe, modular, parallel web rendering engine";
    homepage = "https://servo.org";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ supinie ];
    mainProgram = "verso";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

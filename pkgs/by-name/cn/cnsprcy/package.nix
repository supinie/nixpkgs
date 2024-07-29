{
  lib,
  fetchFromSourcehut,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage rec {
  RUSTC_BOOTSTRAP = true;

  pname = "cnsprcy";
  version = "0.2.0-unstable-2023-12-10";

  src = fetchFromSourcehut {
    owner = "~xaos";
    repo = pname;
    rev = "4da84dd0b6b5a5c44108809cafa0cd33778cb3e8";
    hash = "sha256-YzEwBX1pATWk8QQ2rKa8q40SHGj/HBvSdtZPP/pV1f8=";
  };

  # dependencies are out of date and won't compile
  # unable to cut a PR to upstream so can patch here until upstream accepts our patch
  cargoPatches = [ ./Cargo.lock.patch ];

  cargoHash = "sha256-a6dxIaUz6VvHb7/WCLthaub4cgTE6fMTntvEayLacjE=";

  buildInputs = [ sqlite ];

  meta = {
    description = "End to end encrypted connections between trusted devices";
    homepage = "https://git.sr.ht/~xaos/cnsprcy";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ supinie ];
  };
}

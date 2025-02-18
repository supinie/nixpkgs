{
  lib,
  fetchFromGitHub,
  php81,
  nix-update-script,
}:

php81.buildComposerProject (finalAttrs: {
  pname = "n98-magerun";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "netz98";
    repo = "n98-magerun";
    rev = finalAttrs.version;
    hash = "sha256-/RffdYgl2cs8mlq4vHtzUZ6j0viV8Ot/cB/cB1dstFM=";
  };

  vendorHash = "sha256-n608AY6AQdVuN3hfVQk02vJQ6hl/0+4LVBOsBL5o3+8=";

  passthru.updateScript = nix-update-script {
    # Excludes 1.x versions from the Github tags list
    extraArgs = [
      "--version-regex"
      "^(2\\.(.*))"
    ];
  };

  meta = {
    changelog = "https://magerun.net/category/magerun/";
    description = "Swiss army knife for Magento1/OpenMage developers";
    homepage = "https://magerun.net/";
    license = lib.licenses.mit;
    mainProgram = "n98-magerun";
    maintainers = lib.teams.php.members;
  };
})

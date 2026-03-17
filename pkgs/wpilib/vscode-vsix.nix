{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  libsecret,
  nodejs_20,
  fetchpatch2,
  fetchurl,
  unzip,
}:
buildNpmPackage (finalAttrs: {
  pname = "wpilib-vscode-vsix";
  version = "2026.2.1";

  src = fetchFromGitHub {
    owner = "wpilibsuite";
    repo = "vscode-wpilib";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RB8oA+KvB1Lcd8parD4xfjxPyaHp1VY+5uKqxbYdVKI=";
  };

  sourceRoot = "${finalAttrs.src.name}/vscode-wpilib";

  npmDepsHash = "sha256-jzbys0JkPA5zaay7me+IpuxUAKxF5kfzTRfrPx9eeq8=";

  # Fixes project creation, see:
  # https://github.com/frc4451/frc-nix/issues/64
  # https://github.com/wpilibsuite/vscode-wpilib/pull/854
  patches = [
    (fetchpatch2 {
      url = "https://patch-diff.githubusercontent.com/raw/wpilibsuite/vscode-wpilib/pull/854.patch";
      hash = "sha256-JycCb3JVvez4vvtXh9/Lv5R4XfH/HUoh5Le7GKb5x/M=";
    })
  ];

  patchFlags = [ "-p2" ];

  buildInputs = [ libsecret ];
  nativeBuildInputs = [
    pkg-config
    unzip
  ];
  nodejs = nodejs_20;

  # HACK: gradle is a pain to use inside of nix, so we just nab the existing
  # vsix, extract it, and grab the resources folder from it for our built
  # extension.
  resources-vsix = fetchurl {
    url = "https://github.com/wpilibsuite/vscode-wpilib/releases/download/v${finalAttrs.version}/vscode-wpilib-${finalAttrs.version}.vsix";
    hash = "sha256-Qj9CHQk8ODZiILGEbhBdBl5wLpAf9RsYa7avYT4ns7Y=";
    name = "vscode-wpilib-${finalAttrs.version}.zip";
  };
  preBuild = ''
    mkdir ./resources-vsix
    unzip ${finalAttrs.resources-vsix} -d ./resources-vsix
    rm -rf ./resources
    cp -r ./resources-vsix/extension/resources ./resources/
    rm -rf ./resources-vsix
  '';

  dontNpmBuild = true;
  buildPhase = ''
    runHook preBuild
    npm run vscePackage
    runHook postBuild
  '';

  # The `*.vsix` file is in the end a simple zip file, so for compatibility
  # with older versions of nixpkgs, we change the extension to .zip so that the
  # existing `unzip` hooks can take care of the unpacking.
  installPhase = ''
    runHook preInstall
    install -D *.vsix $out/vscode-wpilib-${finalAttrs.version}.zip
    runHook postInstall
  '';

  meta = {
    description = "Visual Studio Code WPILib extension";
    homepage = "https://github.com/wpilibsuite/vscode-wpilib";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
})

{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  libsecret,
  nodejs_20,
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

  buildInputs = [ libsecret ];
  nativeBuildInputs = [ pkg-config ];
  nodejs = nodejs_20;

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

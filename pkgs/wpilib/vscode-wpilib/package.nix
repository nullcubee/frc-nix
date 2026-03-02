{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  vscode-utils,
  pkg-config,
  libsecret,
}:
let
  pname = "vscode-wpilib";
  version = "2026.2.1";
  vscodeExtPublisher = "wpilibsuite";

  src = fetchFromGitHub {
    owner = "wpilibsuite";
    repo = "vscode-wpilib";
    rev = "v${version}";
    hash = "sha256-RB8oA+KvB1Lcd8parD4xfjxPyaHp1VY+5uKqxbYdVKI=";
  };

  vsix = buildNpmPackage {
    name = "${pname}-${version}.vsix";
    inherit version;
    src = "${src}/vscode-wpilib";
    npmDepsHash = "sha256-jzbys0JkPA5zaay7me+IpuxUAKxF5kfzTRfrPx9eeq8=";
    buildInputs = [ libsecret ];
    nativeBuildInputs = [ pkg-config ];
    dontNpmBuild = true;
  };
in
vscode-utils.buildVscodeExtension {
  inherit
    pname
    version
    vscodeExtPublisher
    vsix
    ;

  vscodeExtUniqueId = "${vscodeExtPublisher}.${pname}";
  vscodeExtName = "${pname}";

  src = vsix;

  # Package metadata
  meta = {
    description = "Visual Studio Code WPILib extension";
    homepage = "https://github.com/wpilibsuite/vscode-wpilib";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}

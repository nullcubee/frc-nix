{
  vscode-utils,
  unzip,
  lib,
  vscode-vsix,
}:
vscode-utils.buildVscodeExtension rec {
  inherit (vscode-vsix) version;

  pname = "${vscodeExtPublisher}-${vscodeExtName}";
  name = "${vscodeExtPublisher}-${vscodeExtName}-${version}";

  # The `*.vsix` file is in the end a simple zip file, so for compatibility
  # with older versions of nixpkgs, we change the extension to .zip so that the
  # existing `unzip` hooks can take care of the unpacking.
  src = "${vscode-vsix}/vscode-wpilib-${version}.zip";
  nativeBuildInputs = [ unzip ];

  # VSCode Metadata
  vscodeExtPublisher = "wpilibsuite";
  vscodeExtName = "vscode-wpilib";
  vscodeExtUniqueId = "wpilibsuite.vscode-wpilib-${version}";

  # Package metadata
  meta = {
    description = "Visual Studio Code WPILib extension";
    homepage = "https://github.com/wpilibsuite/vscode-wpilib";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}

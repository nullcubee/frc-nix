{
  vscode-utils,
  lib,
  vscode-vsix,
}:
vscode-utils.buildVscodeExtension rec {
  inherit (vscode-vsix) version;

  pname = "${vscodeExtPublisher}-${vscodeExtName}";
  name = "${vscodeExtPublisher}-${vscodeExtName}-${version}";

  src = "${vscode-vsix}/vscode-wpilib-${version}.vsix";

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

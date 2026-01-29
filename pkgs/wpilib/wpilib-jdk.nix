{
  fetchurl,
  stdenvNoCC,
  callPackage,
}:
let
  version = "2026.2.1";

  jdkLinuxBase = fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/5b4a87debd9f8bd01ef3d44de33e7c53ef12def0/pkgs/development/compilers/temurin-bin/jdk-linux-base.nix";
    hash = "sha256-i7zVtadsSF7QAN5oCD6Jb9bTLIraFEnO/+JUMbHNZ30=";
  };

  sources = {
    packageType = "jdk";
    "x86_64" = {
      inherit version;
      artifacts = "WPILib_Linux-${version}-artifacts.tar.gz";
      url = "https://packages.wpilib.workers.dev/installer/v${version}/Linux/WPILib_Linux-${version}.tar.gz";
      sha256 = "0mn657w5mw0wlg5zzd96zcsi7ngr59khwgjlaqrpa6sx1fz92rf3";
    };
    "aarch64" = {
      inherit version;
      artifacts = "WPILib_LinuxArm64-${version}-artifacts.tar.gz";
      url = "https://packages.wpilib.workers.dev/installer/v${version}/LinuxArm64/WPILib_LinuxArm64-${version}.tar.gz";
      sha256 = "tN7Vugts3NZPC6DaPEIiC7QuG8TY03PlsoExGFrP+CQ=";
    };
  };

  makeJdkLinux =
    opts:
    (callPackage (import jdkLinuxBase opts) { }).overrideAttrs (oa: {
      installPhase = ''
        tar -xzf ${sources.${stdenvNoCC.hostPlatform.parsed.cpu.name}.artifacts} jdk/
        export sourceRoot="$sourceRoot/jdk"
      ''
      + oa.installPhase;
    });
in
makeJdkLinux {
  name-prefix = "wpilib";
  brand-name = "WPILib";
  sourcePerArch = sources;
}

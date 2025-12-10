{
  description = "Nix packages for the FIRST Robotics Competition, maintained by team 4451 (originally created by 3636).";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.treefmt-nix.flakeModule
    ];

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "armv7l-linux"
      "armv6l-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    flake = {
      githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
        checks = inputs.nixpkgs.lib.getAttrs [ "x86_64-linux" ] inputs.self.packages;
      };

      overlays.default = final: prev: {
        advantagescope = final.callPackage ./pkgs/advantagescope { };
        choreo = final.callPackage ./pkgs/choreo { };
        elastic-dashboard = final.callPackage ./pkgs/elastic-dashboard { };
        pathplanner = final.callPackage ./pkgs/pathplanner { };
        wpilib = final.lib.recurseIntoAttrs (final.callPackage ./pkgs/wpilib { });
        frc-nix-update = final.callPackage ./pkgs/frc-nix-update { };

        vscode-extensions = prev.vscode-extensions // { wpilibsuite.vscode-wpilib = final.wpilib.vscode-wpilib; };
      };
    };

    perSystem = { pkgs, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.self.overlays.default
        ];
        config = { };
      };

      # Packages exposed through flake outputs
      packages = {
        inherit (pkgs)
          advantagescope
          choreo
          elastic-dashboard
          pathplanner
          frc-nix-update
          ;
        inherit (pkgs.wpilib)
          datalogtool
          glass
          outlineviewer
          pathweaver
          roborioteamnumbersetter
          robotbuilder
          shuffleboard
          smartdashboard
          sysid
          wpical
          vscode-wpilib
          wpilib-utility
          ;
      };

      treefmt = {
        programs = {
          nixpkgs-fmt.enable = true;
          cljfmt.enable = true;
          shellcheck = {
            enable = true;
            excludes = [
              ".envrc"
            ];
          };
          prettier.enable = true;
        };
      };

      devShells.default = pkgs.mkShell {
        name = "frc-nix";
        packages = with pkgs; [
          nushell
          frc-nix-update
        ];
      };
    };
  };
}

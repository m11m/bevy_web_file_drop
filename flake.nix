{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      rust-overlay,
      treefmt-nix,
      ...
    }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ] (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          targets = [ "wasm32-unknown-unknown" ];
        };

        build_inputs = pkgs.lib.optionals pkgs.stdenv.isLinux (
          with pkgs;
          [
            alsa-lib
            libX11
            libXcursor
            libXi
            libXrandr
            libxkbcommon
            udev
            vulkan-loader
            wayland
          ]
        );

        native_build_inputs = with pkgs; [
          cargo-auditable
          pkg-config
          trunk
          wasm-bindgen-cli
        ];

        code = pkgs.callPackage ./. { inherit pkgs build_inputs native_build_inputs; };

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs = {
            actionlint.enable = true;
            deadnix.enable = true;
            jsonfmt.enable = true;
            mdformat.enable = true;
            nixfmt = {
              enable = true;
              strict = true;
            };
            oxipng.enable = true;
            prettier = {
              enable = true;
              includes = [
                "*.css"
                "*.html"
                "*.js"
                "*.json"
                "*.ts"
              ];
            };
            rustfmt = {
              enable = true;
              package = rustToolchain;
            };
            statix.enable = true;
            taplo.enable = true;
            yamlfmt.enable = true;
          };
        };
      in
      rec {
        packages = code // {
          all = pkgs.symlinkJoin {
            name = "all";
            paths = with code; [
              example
              lib
            ];
          };

          example = pkgs.symlinkJoin {
            name = "example";
            paths = with code; [ example ];
          };

          lib = pkgs.symlinkJoin {
            name = "lib";
            paths = with code; [ lib ];
          };

          default = packages.all;
          override = packages.all;
          overrideDerivation = packages.all;
        };

        devShells.default = pkgs.mkShell {
          buildInputs =
            (with pkgs; [
              cargo-edit
              cargo-release
              cargo-nextest
            ])
            ++ [ rustToolchain ]
            ++ build_inputs;
          nativeBuildInputs = native_build_inputs;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath build_inputs;
        };

        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
        };
      }
    );
}

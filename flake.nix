{
  description = "A very basic flake";
  
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      flake-utils.url = "github:numtide/flake-utils";

      fenix.url = "github:nix-community/fenix";
      naersk.url = "github:nix-community/naersk";

      pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks, naersk, fenix }:
  
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              fenix.overlay
            ];
          };
          toolchain = fenix.packages.${system}.fromToolchainFile {
            file = ./rust-toolchain.toml;
            sha256 = "sha256-5sAwt7WkNNp8tJcLgZZ2aq2dNka7IuC5o6OZ5HIhXa0=";
          };
          naersk' = pkgs.callPackage naersk {
            cargo = toolchain;
            rustc = toolchain;
          };
          rust_kernel = with naersk'; with pkgs; buildPackage {
            doCheck = true;
#            buildInputs = [ cargo-bootimage cargo-runner ];
            checkInputs = [ toolchain ];
            name = "rust_kernel";
            version = "0.1.0";
            src = ./.;
          };
        in
        {
          # For `nix flake check`
          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                cargo-check.enable = true;
                clippy.enable = false;
                rustfmt.enable = true;
              };
            };
          };
  
          # For `nix develop` (optional, can be skipped):
          devShell = with pkgs; mkShell {
            nativeBuildInputs = [
              toolchain
              libiconv
            ];
            buildInputs = [
              rust-analyzer-nightly
#              act
#              nixfmt
#              cargo-watch
#              cargo-bootimage
#              cargo-runner
            ];
            shellHook = ''
              ${self.checks.${system}.pre-commit-check.shellHook}
            '';
            RUST_SRC_PATH = "${rust.packages.stable.rustPlatform.rustLibSrc}";
          };
  
          # For `nix build` & `nix run`:
          defaultPackage = rust_kernel;
        }
      );
  }

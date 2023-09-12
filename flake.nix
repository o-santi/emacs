{
  description = "Santi's emacs configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    from-elisp = {
      url = "github:talyz/fromElisp";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, emacs-overlay, flake-utils, from-elisp }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ emacs-overlay.overlays.default ];
        };
      in {
        packages = {
          default = pkgs.callPackage ./emacs.nix {
            inherit pkgs from-elisp;
          };
        };
      });
}

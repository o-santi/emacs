{
  description = "Santi's emacs configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    from-elisp = {
      url = "github:o-santi/from-elisp";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, emacs-overlay, flake-utils, from-elisp }:
    flake-utils.lib.eachDefaultSystem (system: {
      nixosModules.default = (import ./emacs.nix) {
        inherit from-elisp emacs-overlay;
      };
    });
}

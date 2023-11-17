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
    flake-utils.lib.eachDefaultSystem (system:
      let emacs = (import ./emacs.nix) {
            inherit from-elisp emacs-overlay nixpkgs system;
          };
      in {
        packages.default = emacs { is-nixos-module = false; };
        nixosModules.default = {pkgs, ...}: {
          config = {
            nixpkgs.overlays = [ emacs-overlay.overlays.default ];
            environment.systemPackages = [
              (emacs { is-nixos-module = true; })
              (pkgs.python3.withPackages (p: (with p; [
                python-lsp-server
                python-lsp-ruff
                pylsp-mypy
              ])))
              pkgs.nil
              pkgs.rust-analyzer
              pkgs.parallel
            ];
            fonts.packages = with pkgs; [
              emacs-all-the-icons-fonts
              (nerdfonts.override { fonts = ["Iosevka"]; })
            ];
          };
        };
      }
    );
}
  

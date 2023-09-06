{ pkgs, ... }:
let
  pkgs_outside_emacs = [
    pkgs.emacs-all-the-icons-fonts
    pkgs.python311Packages.python-lsp-server
    pkgs.pylint
    pkgs.nil
  ];
in
(pkgs.emacsWithPackagesFromUsePackage {
  package = pkgs.emacs-git.override { withGTK3 = true; };
  defaultInitFile = true;
  config = ./config.el;
  alwaysEnsure = true;
  extraEmacsPackages = epkgs: with epkgs; [
    (treesit-grammars.with-grammars (g: with g; [
      tree-sitter-rust
      tree-sitter-python
    ]))
  ] ++ pkgs_outside_emacs;
})



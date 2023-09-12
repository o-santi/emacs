{ pkgs, from-elisp }:
let
  fonts = [
    pkgs.emacs-all-the-icons-fonts
    (pkgs.nerdfonts.override { fonts = ["Iosevka"]; })
  ];
  outside-emacs = [
    pkgs.python311Packages.python-lsp-server
    pkgs.pylint
    pkgs.nil
  ];
  from-org-mode = (pkgs.callPackage from-elisp {
    inherit pkgs;
  }).parseOrgModeBabelElisp;
  lisp-to-str = (pkgs.callPackage ./sexp.nix pkgs).sexp-list-to-str "\n";
  org-tangle = org-file: (lisp-to-str (from-org-mode (builtins.readFile org-file)));
in
(pkgs.emacsWithPackagesFromUsePackage {
  package = pkgs.emacs-git.override { withGTK3 = true; };
  config = ./README.org;
  alwaysEnsure = true;
  defaultInitFile = pkgs.writeText "default.el" (org-tangle ./README.org);
  extraEmacsPackages = epkgs: with epkgs; [
    (treesit-grammars.with-grammars (g: with g; [
      tree-sitter-rust
      tree-sitter-python
    ]))
  ] ++ outside-emacs ++ fonts;
})

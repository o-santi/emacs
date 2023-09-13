{ pkgs, from-elisp }:
let
  fonts = [
  #  pkgs.emacs-all-the-icons-fonts
  #  (pkgs.nerdfonts.override { fonts = ["Iosevka"]; })

  ];
  outside-emacs = [
    pkgs.python311Packages.python-lsp-server
    pkgs.pylint
    pkgs.nil
  ];
  org-tangle-elisp-blocks = (pkgs.callPackage ./org.nix {inherit pkgs from-elisp;}).org-tangle ({ language, flags } :
    let is-elisp = (language == "emacs-lisp") || (language == "elisp");
        is-tangle = if flags ? ":tangle" then
          flags.":tangle" == "yes" || flags.":tangle" == "y" else false;
    in is-elisp && is-tangle
  );
  config-el = pkgs.writeText "config.el" (org-tangle-elisp-blocks (builtins.readFile ./README.org));
in
(pkgs.emacsWithPackagesFromUsePackage {
  package = pkgs.emacs-git.override { withGTK3 = true; };
  config = config-el;
  alwaysEnsure = true;
  defaultInitFile = true;
  extraEmacsPackages = epkgs: with epkgs; [
    (treesit-grammars.with-grammars (g: with g; [
      tree-sitter-rust
      tree-sitter-python
    ]))
  ] ++ outside-emacs ++ fonts;
})

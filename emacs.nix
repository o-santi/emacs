{ from-elisp, emacs-overlay, nixpkgs, system } : { is-nixos-module } :
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ emacs-overlay.overlays.default ];
  };
  outside-emacs = [
    (pkgs.python3.withPackages (p: (with p; [
      python-lsp-server
      python-lsp-ruff
      pylsp-mypy
    ])))
    pkgs.nil
  ];
  org-tangle-elisp-blocks = (pkgs.callPackage ./org.nix {inherit pkgs from-elisp;}).org-tangle ({ language, flags } :
    let is-elisp = (language == "emacs-lisp") || (language == "elisp");
        is-tangle = if flags ? ":tangle" then
          flags.":tangle" == "yes" || flags.":tangle" == "y" else false;
    in is-elisp && is-tangle
  );
  config-el = pkgs.substituteAll {
    name = "default.el";
    isnixosmodule = if is-nixos-module then "t" else "nil";
    src = pkgs.writeText "config.el" (org-tangle-elisp-blocks (builtins.readFile ./README.org));
  };
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
  ] ++ outside-emacs;
  override = final: prev: {
    final.buildInputs = prev.buildInputs ++ outside-emacs;
  };
})

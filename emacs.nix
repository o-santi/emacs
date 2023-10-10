{ pkgs, from-elisp }:
let
  fonts = [
  #  pkgs.emacs-all-the-icons-fonts
  #  (pkgs.nerdfonts.override { fonts = ["Iosevka"]; })

  ];
  # taken from
  # https://github.com/NixOS/nixpkgs/issues/229337
  # python = pkgs.python3.override {
  #   packageOverrides = self: super: {
  #     python-lsp-server = super.python-lsp-server.overridePythonAttrs (oldAttrs: {
  #       propagatedBuildInputs = oldAttrs.propagatedBuildInputs or [] ++ [
  #         self.python-lsp-ruff
  #       ];
  #     });
  #     python-lsp-ruff = super.python-lsp-ruff.overridePythonAttrs (oldAttrs: {
  #       postPatch = oldAttrs.postPatch or '''' + ''
  #         sed -i '/python-lsp-server/d' pyproject.toml
  #       '';
      
  #       nativeBuildInputs = with super; [
  #         setuptools          
  #       ];

  #       propagatedBuildInputs = with super; [
  #         lsprotocol
  #         tomli
  #       ];
  #       doCheck = false;
  #     });
  #   };
  # };
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

pkgs: rec {
  sexp-to-str = sexp:
    let
      type = sexp.type;
    in
      if type == "list" then
        "(${sexp-list-to-str " " sexp.value})"
      else if type == "symbol" then
        if (builtins.typeOf sexp.value) == "bool" then "t" else "${sexp.value}"
      else if type == "string" then
        "\"${sexp.value}\""
      else if type == "integer" then
        "${builtins.toString sexp.value}"
      else if type == "quote" then
        "'${sexp-to-str sexp.value}"
      else if type == "backquote" then
        "`${sexp-to-str sexp.value}"
      else if type == "expand" then
        ",${sexp-to-str sexp.value}"
      else if type == "character" then
        "${sexp.value}"
      else if type == "function" then
        "#'${sexp-to-str sexp.value}"
      else if type == "dot" then
        "."
      else
        throw "Cant eval expression of type ${type} at line=${builtins.toString sexp.line}";
  sexp-list-to-str = sep: list: builtins.concatStringsSep sep (map sexp-to-str list);
}

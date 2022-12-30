{lib}:

with lib;

rec {
  wrapLuaConfig = luaConfig: ''
    lua << EOF
    ${luaConfig}
    EOF
  '';

  wrapVimConfig = vimConfig: ''
    vim.cmd([[
      ${vimConfig}
    ]])
  '';

  toLuaObject = args: 
    if builtins.isAttrs args then
      if hasAttr "__raw" args then
        args.__raw
      else
      "{" + (concatStringsSep "," (mapAttrsToList (n: v: 
        if head (stringToCharacters n) == "@" then
          toLuaObject v
        else 
          "[${toLuaObject n}] = " + (toLuaObject v))
        (filterAttrs (n: v: 
          !isNull v && toLuaObject v != "{}") args))) + "}"
    else if builtins.isList args then
      "{" + concatMapStringsSep "," toLuaObject args + "}"
    else if builtins.isBool args then
      boolToString args
    else if builtins.isString args then
      "\"${args}\""
    else if builtins.isInt args then
      toString args
    else 
      "";

}

{ config, lib, helpers, ... }:
with lib;

let
  cfg = config.vim;
  optOp = op: mkOption {
    type = types.attrsOf types.anything;
    description = "Option to ${op}";
    default = { };
  };
in
{
  options.vim = {
    opts = mkOption {
      type = types.submodule {
        options = {
          set = optOp "set";
          prepend = optOp "prepend";
          append = optOp "append";
        };
      };
      default = { };
      description = "The configuration options, e.g. line numbers";
    };
  };

  config = {
    vim.luaConfig = 
    optionalString (cfg.opts.set != { }) ''
      local setOpts = ${nvim.lua.toLuaObject cfg.opts.set}
      for k,v in pairs(setOpts) do
        vim.o[k] = v
      end
    ''
    + optionalString (cfg.opts.append != { }) ''
      local appendOpts = ${nvim.lua.toLuaObject cfg.opts.append}
      for k,v in pairs(appendOpts) do
        vim.o[k] = vim.o[k] .. "," .. v
      end
    ''
    + optionalString (cfg.opts.prepend != { }) ''
      local prependOpts = ${nvim.lua.toLuaObject cfg.opts.prepend}
      for k,v in pairs(prependOpts) do
        vim.o[k] = v .. "," .. vim.o[k]
      end
    '';
  };
}

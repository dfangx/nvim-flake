{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.vim.dap;
in
{
  options.vim.dap = {
    enable = mkEnableOption "Whether to enable lualine";
    debuggers = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "Debugger definition.";
    };
    configurations = mkOption {
      type = types.attrsOf (types.listOf (types.attrsOf types.anything));
      default = { };
      description = "Debugger configuration";
    };
  };

  config = {
    vim.startPlugins = with pkgs.vimPlugins; [
      nvim-dap
    ];

    vim.luaRequires = {
      dap = "dap";
    };

    vim.luaConfig = ''
      dap.adapters = ${nvim.lua.toLuaObject cfg.debuggers}
      

      dap.configurations = ${nvim.lua.toLuaObject cfg.configurations}
    '';
  };
}

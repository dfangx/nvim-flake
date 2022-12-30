{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.vim.lualine;
in
{
  options.vim.lualine = {
    enable = mkEnableOption "Whether to enable lualine";
  };

  config = {
    vim.startPlugins = with pkgs.vimPlugins; [
      lualine-nvim
      lualine-lsp-progress
    ];

    vim.luaConfig = ''
      require'lualine'.setup { 
        sections = {
          lualine_c = { 'filename', 'lsp_progress' }
        }
      } 
    '';
  };
}

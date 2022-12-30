{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.vim.fzf;
in
{
  options.vim.fzf = {
    enable = mkEnableOption ''
      Enable fzf-lua. This exposes the following symbols:
        - fzf = require'fzf-lua'
        - fzfActions = require'fzf-lua.actions'
    '';
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [
      fzf-lua
    ];

    vim.luaRequires = {
      fzf = "fzf-lua";
      fzfActions ="fzf-lua.actions";
    };

    vim.luaConfig = ''
      fzf = require'fzf-lua'
      actions = require'fzf-lua.actions'
      
      fzf.setup {
          winopts = {
              split = 'new',
              win_height = 0.5
          },
          fzf_layout = 'default',
          preview_vertical = 'up:70%',
          preview_wrap = 'wrap'
      }
    '';
  };
}


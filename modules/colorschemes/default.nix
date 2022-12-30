{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.vim.colorschemes;
in
{
  imports = [
    ./nord.nix
  ];

  options.vim.colorschemes = {
    colorscheme = mkOption {
      type = types.enum ["nord" ""];
      description = "Colorscheme to use";
      default = "";
    };
  };

  config = {
    vim.opts.set.termguicolors = true;
    vim.luaConfig = optionalString (cfg.colorscheme != "") 
      "vim.cmd('colorscheme ${cfg.colorscheme}')";
  };
}

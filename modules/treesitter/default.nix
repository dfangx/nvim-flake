{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.vim.treesitter;
in
{
  options.vim.treesitter = {
    enable = mkEnableOption "Whether to enable treesitter";
    highlight = mkEnableOption "Whether to enable treesitter highlight";
    fold = mkEnableOption "Whether to enable treesitter fold";
    grammars = mkOption {
      type = types.oneOf [
        (types.enum(["all"]))
        (types.listOf types.str)
      ];
      default = "all";
      description = "List of packages to install. <all> installs all grammars"; 
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = let
      mapTSGrammarStrToPkg = grammars: map (g: pkgs.tree-sitter-grammars."tree-sitter-${g}") grammars;
      tsPkg = if cfg.grammars == "all" then
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      else if cfg.grammars != [ ] then
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (_: mapTSGrammarStrToPkg cfg.grammars))
      else
        pkgs.vimPlugins.nvim-treesitter;
    in
    [
      tsPkg
    ];

    vim.opts.set = mkIf cfg.fold {
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
    };

    vim.luaConfig = ''
      require'nvim-treesitter.configs'.setup {
        highlight = { enable = ${nvim.lua.toLuaObject cfg.highlight} }
      }
    '';
  };
}

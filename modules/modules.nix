{ pkgs, ... }:
let
  modules = [
    ./neorg
    ./dap
    ./autopairs
    ./fzf
    ./treesitter
    ./colorschemes
    ./lsp
    ./autocompletion
    ./statusbar
    ./core
  ];
  pkgsModules = { config, ... }: {
    config = {
      _module.args.baseModules = modules;
      _module.args.pkgs = pkgs;
    };
  };
in
  modules ++ [pkgsModules]

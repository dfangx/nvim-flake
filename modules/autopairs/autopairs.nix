{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.vim.autopairs;
  srcType = type: mkOption {
    type = types.attrsOf types.str;
    default = { };
    description = "Completion package and source names for ${type}";
  };
in
{
  options.vim.autopairs = {
    enable = mkEnableOption "Whether to enable nvim-cmp";
    fastWrap = mkEnableOption "Whether to enable fast wrap";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [
        nvim-autopairs
    ];

    vim.luaConfig = let
      fastWrap = optionalString cfg.enable "fast_wrap = {}";
    in
    ''
      require'nvim-autopairs'.setup{ ${fastWrap} }
    '';
  };
}


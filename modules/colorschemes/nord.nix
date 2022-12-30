{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.vim.colorschemes.nord;
in
{
  options.vim.colorschemes.nord = {
    enable = mkEnableOption "Enable nord colorscheme";
    italic = mkEnableOption "Enable italics";
    italicComments = mkEnableOption "Enable italics for comments";
    underline = mkEnableOption "Enable underline";
    uniformDiffBackground = mkEnableOption "Uniform diff background";
    cursorLineNumberBackground = mkEnableOption "Cursor line number background";
  };

  config = mkIf (config.vim.colorschemes.colorscheme == "nord") {
    vim.startPlugins = with pkgs.vimPlugins; [
      nord-vim
    ];

    vim.globalVars = {
      nord_italic = mkIf cfg.italic 1;
      nord_italic_comments = mkIf cfg.italicComments 1;
      nord_underline = mkIf cfg.underline 1;
      nord_uniform_diff_background = mkIf cfg.uniformDiffBackground 1;
      nord_cursor_line_number_background = mkIf cfg.cursorLineNumberBackground 1;
    };
  };
}

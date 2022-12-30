{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.vim.neorg;
in
{
  options.vim.neorg = {
    enable = mkEnableOption "Whether to enable neorg";
    concealer = mkEnableOption "Whether to enable concealer";
    completion = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Whether to enable completion";
          engine = mkOption {
            type = types.enum[ "nvim-cmp" ];
            description = "Completion engine to use";
          };
        };
      };
      description = "Neorg completion";
    };
    journal = mkOption {
      type = types.submodule {
        options = {
          config = mkOption {
            type = types.attrsOf types.anything;
            default = { };
            description = "Configuration for journal.";
          };
        };
      };
    };
    dirman = mkOption {
      type = types.submodule {
        options = {
          config = mkOption {
            type = types.attrsOf types.anything;
            default = { };
            description = "Configuration for dirman.";
          };
        };
      };
      default = { };
      description = "Dirman setup";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [
      neorg
      plenary-nvim
    ];

    vim.luaConfig = let
      concealer = optionalString (cfg.concealer) ''
        ["core.norg.concealer"] = { },
      '';
      completion = optionalString(cfg.completion.enable) ''
        ["core.norg.completion"] = {
          config = {
            engine = "${cfg.completion.engine}"
          }
        },
      '';
      journal = optionalString (cfg.journal.config != { }) ''
        ["core.norg.journal"] = ${nvim.lua.toLuaObject cfg.journal},
      '';
      dirman = optionalString (cfg.dirman.config != { }) ''
        ["core.norg.dirman"] = ${nvim.lua.toLuaObject cfg.dirman},
      '';
    in
    ''
      require'neorg'.setup {
        load = {
          ["core.defaults"] = { },
          ["core.keybinds"] = {
            config = {
              default_keybinds = true
            }
          },
          ${concealer}
          ${dirman}
          ${journal}
          ${completion}
        }
      }
    '';
  };
}

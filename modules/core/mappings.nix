{ config, lib, helpers, ... }:
with lib;
let
  cfg = config.vim;

  keymap = types.oneOf [
    types.str
    (types.submodule {
      options = {
        silent = mkOption {
          type = types.bool;
          description = "Whether this mapping should be silent. Equivalent to adding <silent> to a map.";
          default = false;
        };

        nowait = mkOption {
          type = types.bool;
          description = "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.";
          default = false;
        };

        expr = mkOption {
          type = types.bool;
          description = "Means that the action is actually an expression. Equivalent to adding <expr> to a map.";
          default = false;
        };

        noremap = mkOption {
          type = types.bool;
          description = "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";
          default = true;
        };

        action = mkOption {
          type = types.str;
          description = "The action to execute.";
        };
      };
    })
  ];

  keymapType = mode: mkOption {
    description = "Mappings for ${mode} mode";
    type = types.attrsOf keymap;
    default = { };
  };
in
{
  options.vim = {
    keymaps = mkOption {
      type = types.submodule {
        options = {
          normal = keymapType "normal";
          insert = keymapType "insert";
          visual = keymapType "visual";
        };
      };
      default = { };
      description = ''
        Custom keybindings for any mode.
        For plain maps (e.g. just 'map' or 'remap') use maps.normalVisualOp.
      '';
    };
  };

  config =
    let
      genMappings = mode: mappings: 
        mapAttrsToList (keyBind: mappingDetails:
          if builtins.isString mappingDetails then
            {
              inherit mode keyBind;
              action = mappingDetails;
              options = {
                silent = false;
                expr = false;
                nowait = false;
                noremap = true;
              };
            }
          else
            {
              inherit mode keyBind;
              action = mappingDetails.action;
              options = {
                silent = mappingDetails.silent;
                nowait = mappingDetails.nowait;
                expr = mappingDetails.expr;
                noremap = mappingDetails.noremap;
              };
            }
        ) mappings;
      mappings =
        (genMappings "n" cfg.keymaps.normal) ++
        (genMappings "i" cfg.keymaps.insert) ++
        (genMappings "v" cfg.keymaps.visual);
    in
    {
      # TODO: Use vim.keymap.set if on nvim >= 0.7
      vim.luaConfig = optionalString (mappings != [ ]) ''
        local keyMaps = ${nvim.lua.toLuaObject mappings}
        for i, map in ipairs(keyMaps) do
          vim.api.nvim_set_keymap(map.mode, map.keyBind, map.action, map.options)
        end
      '';
    };
}

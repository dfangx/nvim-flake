{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.vim;
  runtime' = filter (f: f.enable) (attrValues cfg.runtime);
  runtime = pkgs.linkFarm "neovim-runtime" (map (x: { name = x.target; path = x.source; }) runtime');
in
{
  options.vim = {
    viAlias = mkOption {
      description = "Enable vi alias";
      type = types.bool;
      default = true;
    };

    vimAlias = mkOption {
      description = "Enable vim alias";
      type = types.bool;
      default = true;
    };

    vimConfig = mkOption {
      description = "vimrc contents";
      type = types.lines;
      default = "";
    };

    globalVars = mkOption {
      type = types.attrsOf types.anything;
      description = "Global variables";
      default = { };
    };

    luaConfig = mkOption {
      description = "vim lua config";
      type = types.lines;
      default = "";
    };

    builtConfig = mkOption {
      internal = true;
      type = types.lines;
      description = "Generated nvim config";
    };

    startPlugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of plugins to startup.";
    };

    optPlugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of plugins to optionally load";
    };

    runtime = mkOption {
      default = { };
      description = "Runtime files to load";
      type = types.attrsOf (types.submodule ( { name, config, ... }:
      { 
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = lib.mdDoc ''
              Whether this /etc file should be generated.  This
              option allows specific /etc files to be disabled.
            '';
          };

          target = mkOption {
            type = types.str;
            description = lib.mdDoc ''
              Name of symlink.  Defaults to the attribute
              name.
            '';
          };

          text = mkOption {
            default = null;
            type = types.nullOr types.lines;
            description = lib.mdDoc "Text of the file.";
          };

          source = mkOption {
            type = types.path;
            description = lib.mdDoc "Path of the source file.";
          };
        };
        config = {
          target = mkDefault name;
          source = mkIf (config.text != null) (
            let name' = "neovim-runtime" + baseNameOf name;
            in mkDefault (pkgs.writeText name' config.text));
        };
      }));
    };

    luaRequires = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Attribute set representing the lua modules that are required";
    };

    autocommands = mkOption {
      default = { };
      type = types.attrsOf (types.submodule {
        options = {
          clear = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to clear autogroup";
          };
          commands = mkOption {
            default = [ ];
            description = "List of commands that go inside this autocommands group";
            type = types.listOf (types.submodule {
              options = {
                events = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                  description = "List of events to listen to";
                };
                pattern = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                  description = "File pattern to trigger autocmd";
                };
                command = mkOption {
                  type = types.str;
                  default = "";
                  description = "Command to run";
                };
              };
            });
          };
        };
      });
    };

    userCommands = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "User defined commands";
    };
  };

  config = let
    vimCfg = cfg.vimConfig;
  in
  {
    vim.startPlugins = with pkgs.vimPlugins; [
      vim-nix
    ];

    vim.opts.prepend.runtimepath = "${runtime}";

    vim.luaConfig = ''
      local globals = ${nvim.lua.toLuaObject cfg.globalVars};
      for k,v in pairs(globals) do
        vim.g[k] = v;
      end

      local userCommands = ${nvim.lua.toLuaObject cfg.userCommands}
      for k,v in pairs(userCommands) do
        vim.api.nvim_create_user_command(k, v, { })
      end

      local autocommands = ${nvim.lua.toLuaObject cfg.autocommands}
      for k,v in pairs(autocommands) do
        vim.api.nvim_create_augroup(k, { clear = v.clear })
        for _,cmd in ipairs(v.commands) do
          vim.api.nvim_create_autocmd(cmd.events, { pattern = cmd.pattern, command = cmd.command, group = k })
        end
      end
    '';
    vim.builtConfig = let
      requires = (concatStringsSep "\n" (mapAttrsToList (k: v: "local ${k} = require'${v}'") cfg.luaRequires));
      wrappedLuaCfg = nvim.lua.wrapLuaConfig (requires + "\n" + cfg.luaConfig);
    in
    ''
      ${wrappedLuaCfg}
      ${vimCfg}
    '';
  };
}

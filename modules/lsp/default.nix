{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.vim.lsp;
in
{
  options.vim.lsp = {
    enable = mkEnableOption "Whether to enable lsp support";
    defaultOnAttach = mkOption {
      type = types.lines;
      default = "";
      description = "Contents for the on_attach function. Argument 'client' is available.";
    };
    defaultCapabilities = mkOption {
      type = types.lines;
      default = "";
      description = "Capabilities for the server";
    };
    servers = mkOption {
      type = types.listOf (types.submodule ( {config, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            default = "";

          };

          onAttach = mkOption {
            type = types.lines;
            default = "";
            description = "Contents for the on_attach function. Argument 'client' is available.";
          };

          capabilities = mkOption {
            type = types.lines;
            default = "";
            description = "Capabilities for the server";
          };

          cmd = mkOption {
            type = types.str;
            description = "Command to use for the server";
          };
        };

        config = {
          cmd = let
            pkgName = if config.name == "rust_analyzer" then
              "rust-analyzer"
            else if config.name == "rnix" then
              "rnix-lsp"
            else
              config.name;
          in
            mkDefault "${pkgs.${pkgName}}/bin/${pkgName}";
        };
      }));
      default = [ ];
      description = "List of enabled servers. The name of the server is the name according to lspconfig";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [
      nvim-lspconfig
    ];

    vim.luaConfig = let
      defaultOnAttach = optionalString (cfg.defaultOnAttach != "") ''
        on_attach = function(client)
          ${cfg.defaultOnAttach}
        end,
      '';
      defaultCapabilities = optionalString (cfg.defaultOnAttach != "") ''
        capabilities = capabilities,
      '';
      defaultLspConfig = optionalString (defaultOnAttach != "" || defaultCapabilities != "") ''
        ${cfg.defaultCapabilities}
        lspconfig.util.default_config = vim.tbl_extend(
          "force",
          lspconfig.util.default_config,
          {
            ${defaultOnAttach}
            ${defaultCapabilities}
          }
        )
      '';

      genSvrSetupStr = servers: optionalString (servers != []) (concatMapStringsSep "\n" (s: 
      let
        svrOnAttach = optionalString (s.onAttach != "") ''
          on_attach = function(client)
            ${s.onAttach}
          end,
        '';
        svrCapabilities = optionalString (s.capabilities != "") ''
          capabilities = capabilities,
        '';
      in
      ''
        ${s.capabilities}
        lspconfig[${nvim.lua.toLuaObject s.name}].setup {
          ${svrOnAttach}
          ${svrCapabilities}
          cmd = { ${nvim.lua.toLuaObject s.cmd} }
        };
      '') servers);
    in
    ''
      local lspconfig = require'lspconfig'
      ${defaultLspConfig}
      ${genSvrSetupStr cfg.servers}
    '';
  };
}
